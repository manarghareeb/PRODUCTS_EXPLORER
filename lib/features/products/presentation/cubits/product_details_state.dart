import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

enum ProductDetailsStatus { initial, loading, success, error }

class ProductDetailsState extends Equatable {
  final ProductDetailsStatus status;
  final ProductEntity? product;
  final String? errorMessage;

  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.errorMessage,
  });

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    ProductEntity? product,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, product, errorMessage];
}
