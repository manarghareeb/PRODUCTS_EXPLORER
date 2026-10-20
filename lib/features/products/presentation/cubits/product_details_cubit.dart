import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_product_details.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;

  int? _currentProductId;
  CancelToken? _cancelToken;

  ProductDetailsCubit({required this.getProductDetailsUseCase})
    : super(const ProductDetailsState());

  Future<void> loadProductDetails(int id) async {
    _currentProductId = id;
    _cancelToken?.cancel('Reloading product details');
    _cancelToken = CancelToken();

    emit(
      state.copyWith(
        status: ProductDetailsStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await getProductDetailsUseCase(
      id,
      cancelToken: _cancelToken,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure.message.contains('cancelled')) return;
        emit(
          state.copyWith(
            status: ProductDetailsStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (product) {
        emit(
          state.copyWith(
            status: ProductDetailsStatus.success,
            product: product,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  void retry() {
    if (_currentProductId != null) {
      loadProductDetails(_currentProductId!);
    }
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('ProductDetailsCubit closed');
    return super.close();
  }
}
