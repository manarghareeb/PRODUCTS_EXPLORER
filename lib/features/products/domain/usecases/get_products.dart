import '../../../../core/network/api_result.dart';
import '../entities/products_response_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  const GetProductsUseCase(this.repository);

  Future<ApiResult<ProductsResponseEntity>> call({
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  }) {
    return repository.getProducts(
      limit: limit,
      skip: skip,
      cancelToken: cancelToken,
    );
  }
}
