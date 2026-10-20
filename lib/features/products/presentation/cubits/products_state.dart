import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

enum ProductsStatus { initial, loading, success, empty, error }

enum PaginationStatus { idle, loading, error }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final PaginationStatus paginationStatus;
  final List<ProductEntity> products;
  final String searchQuery;
  final int total;
  final int skip;
  final bool hasMore;
  final String? errorMessage;
  final String? paginationErrorMessage;
  final bool isRefreshing;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.paginationStatus = PaginationStatus.idle,
    this.products = const [],
    this.searchQuery = '',
    this.total = 0,
    this.skip = 0,
    this.hasMore = true,
    this.errorMessage,
    this.paginationErrorMessage,
    this.isRefreshing = false,
  });

  bool get isSearching => searchQuery.trim().isNotEmpty;

  bool get hasProducts => products.isNotEmpty;

  ProductsState copyWith({
    ProductsStatus? status,
    PaginationStatus? paginationStatus,
    List<ProductEntity>? products,
    String? searchQuery,
    int? total,
    int? skip,
    bool? hasMore,
    String? errorMessage,
    String? paginationErrorMessage,
    bool? isRefreshing,
    bool clearErrorMessage = false,
    bool clearPaginationErrorMessage = false,
  }) {
    return ProductsState(
      status: status ?? this.status,
      paginationStatus: paginationStatus ?? this.paginationStatus,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      paginationErrorMessage: clearPaginationErrorMessage
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    paginationStatus,
    products,
    searchQuery,
    total,
    skip,
    hasMore,
    errorMessage,
    paginationErrorMessage,
    isRefreshing,
  ];
}
