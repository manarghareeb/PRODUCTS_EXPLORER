import '../../../../core/network/api_result.dart';
import '../entities/products_response_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;

  const SearchProductsUseCase(this.repository);

  Future<ApiResult<ProductsResponseEntity>> call({
    required String query,
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  }) {
    return repository.searchProducts(
      query: query,
      limit: limit,
      skip: skip,
      cancelToken: cancelToken,
    );
  }
}
