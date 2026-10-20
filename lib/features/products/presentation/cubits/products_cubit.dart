import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart'; 
import '../../domain/entities/products_response_entity.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/search_products.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  static const int pageSize = 20;
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);

  final Debouncer _debouncer = Debouncer();
  CancelToken? _cancelToken;
  int _requestId = 0;

  ProductsCubit({
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
  }) : super(const ProductsState());

  Future<void> loadProducts({bool isRefresh = false}) async {
    _debouncer.cancel(); 
    _cancelToken?.cancel('Reloading products');
    _cancelToken = CancelToken();
    final currentRequestId = ++_requestId;

    if (isRefresh) {
      emit(
        state.copyWith(
          isRefreshing: true,
          clearErrorMessage: true,
          clearPaginationErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ProductsStatus.loading,
          paginationStatus: PaginationStatus.idle,
          clearErrorMessage: true,
          clearPaginationErrorMessage: true,
        ),
      );
    }

    final result = state.isSearching
        ? await searchProductsUseCase(
            query: state.searchQuery,
            limit: pageSize,
            skip: 0,
            cancelToken: _cancelToken,
          )
        : await getProductsUseCase(
            limit: pageSize,
            skip: 0,
            cancelToken: _cancelToken,
          );

    if (isClosed || currentRequestId != _requestId) return;

    result.fold(
      (failure) {
        if (failure.message.contains('cancelled')) return;
        emit(
          state.copyWith(
            status: state.products.isEmpty
                ? ProductsStatus.error
                : state.status,
            errorMessage: failure.message,
            isRefreshing: false,
          ),
        );
      },
      (response) {
        handleInitialLoadSuccess(response);
      },
    );
  }

  void onSearchChanged(String query) {
    final trimmed = query.trim();

    if (trimmed == state.searchQuery && state.status != ProductsStatus.error) {
      return;
    }

    if (trimmed.isEmpty) {
      _debouncer.cancel();
      emit(
        state.copyWith(
          searchQuery: '',
          clearErrorMessage: true,
          clearPaginationErrorMessage: true,
        ),
      );
      loadProducts();
      return;
    }

    _debouncer.debounce(
      duration: searchDebounceDuration,
      onDebounce: () {
        performSearch(trimmed);
      },
    );
  }

  void searchNow(String query) {
    final trimmed = query.trim();
    _debouncer.cancel();
    if (trimmed.isEmpty) {
      clearSearch();
    } else {
      performSearch(trimmed);
    }
  }

  void clearSearch() {
    _debouncer.cancel();
    emit(
      state.copyWith(
        searchQuery: '',
        clearErrorMessage: true,
        clearPaginationErrorMessage: true,
      ),
    );
    loadProducts();
  }

  Future<void> performSearch(String query) async {
    _cancelToken?.cancel('New search query');
    _cancelToken = CancelToken();
    final currentRequestId = ++_requestId;

    emit(
      state.copyWith(
        status: ProductsStatus.loading,
        searchQuery: query,
        paginationStatus: PaginationStatus.idle,
        clearErrorMessage: true,
        clearPaginationErrorMessage: true,
      ),
    );

    final result = await searchProductsUseCase(
      query: query,
      limit: pageSize,
      skip: 0,
      cancelToken: _cancelToken,
    );

    if (isClosed || currentRequestId != _requestId) return;

    result.fold(
      (failure) {
        if (failure.message.contains('cancelled')) return;
        emit(
          state.copyWith(
            status: ProductsStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        handleInitialLoadSuccess(response);
      },
    );
  }

  void handleInitialLoadSuccess(ProductsResponseEntity response) {
    if (response.products.isEmpty) {
      emit(
        state.copyWith(
          status: ProductsStatus.empty,
          products: const [],
          total: response.total,
          skip: response.skip,
          hasMore: false,
          isRefreshing: false,
          paginationStatus: PaginationStatus.idle,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ProductsStatus.success,
          products: response.products,
          total: response.total,
          skip: response.skip,
          hasMore: response.hasMore,
          isRefreshing: false,
          paginationStatus: PaginationStatus.idle,
          clearErrorMessage: true,
        ),
      );
    }
  }

  Future<void> loadMoreProducts() async {
    if (state.paginationStatus == PaginationStatus.loading ||
        !state.hasMore ||
        state.status == ProductsStatus.loading ||
        state.isRefreshing) {
      return;
    }

    final nextSkip = state.products.length;

    emit(
      state.copyWith(
        paginationStatus: PaginationStatus.loading,
        clearPaginationErrorMessage: true,
      ),
    );

    final currentRequestId = _requestId;

    final result = state.isSearching
        ? await searchProductsUseCase(
            query: state.searchQuery,
            limit: pageSize,
            skip: nextSkip,
          )
        : await getProductsUseCase(limit: pageSize, skip: nextSkip);

    if (isClosed || currentRequestId != _requestId) return;

    result.fold(
      (failure) {
        if (failure.message.contains('cancelled')) return;
        emit(
          state.copyWith(
            paginationStatus: PaginationStatus.error,
            paginationErrorMessage: failure.message,
          ),
        );
      },
      (response) {
        if (response.products.isEmpty) {
          emit(
            state.copyWith(
              paginationStatus: PaginationStatus.idle,
              hasMore: false,
            ),
          );
        } else {
          final updatedProducts = [...state.products, ...response.products];
          final hasMore = updatedProducts.length < response.total;

          emit(
            state.copyWith(
              paginationStatus: PaginationStatus.idle,
              products: updatedProducts,
              total: response.total,
              skip: nextSkip,
              hasMore: hasMore,
              clearPaginationErrorMessage: true,
            ),
          );
        }
      },
    );
  }

  void retryPagination() {
    loadMoreProducts();
  }

  void retry() {
    if (state.paginationStatus == PaginationStatus.error) {
      retryPagination();
    } else if (state.isSearching) {
      performSearch(state.searchQuery);
    } else {
      loadProducts();
    }
  }

  @override
  Future<void> close() {
    _debouncer.cancel();
    _cancelToken?.cancel('ProductsCubit closed');
    return super.close();
  }
}