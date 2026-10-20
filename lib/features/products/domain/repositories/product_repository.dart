import '../../../../core/network/api_result.dart';
import '../entities/product_entity.dart';
import '../entities/products_response_entity.dart';

abstract class ProductRepository {
  Future<ApiResult<ProductsResponseEntity>> getProducts({
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  });

  Future<ApiResult<ProductsResponseEntity>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  });

  Future<ApiResult<ProductEntity>> getProductDetails(
    int id, {
    dynamic cancelToken,
  });
}
