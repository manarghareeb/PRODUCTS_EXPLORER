import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_consumer.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/products_response_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductsResponseModel> getProducts({
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  });

  Future<ProductsResponseModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  });

  Future<ProductModel> getProductDetails(int id, {dynamic cancelToken});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiConsumer apiConsumer;

  const ProductRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<ProductsResponseModel> getProducts({
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  }) async {
    final response = await apiConsumer.get(
      ApiEndpoints.products,
      queryParameters: {'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
    );

    if (response is Map<String, dynamic>) {
      return ProductsResponseModel.fromJson(response);
    } else if (response is Map) {
      return ProductsResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    }
    throw const ParsingException(
      'Unexpected response format from getProducts.',
    );
  }

  @override
  Future<ProductsResponseModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  }) async {
    final response = await apiConsumer.get(
      ApiEndpoints.productsSearch,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
    );

    if (response is Map<String, dynamic>) {
      return ProductsResponseModel.fromJson(response);
    } else if (response is Map) {
      return ProductsResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    }
    throw const ParsingException(
      'Unexpected response format from searchProducts.',
    );
  }

  @override
  Future<ProductModel> getProductDetails(int id, {dynamic cancelToken}) async {
    final response = await apiConsumer.get(
      ApiEndpoints.productDetails(id),
      cancelToken: cancelToken,
    );

    if (response is Map<String, dynamic>) {
      return ProductModel.fromJson(response);
    } else if (response is Map) {
      return ProductModel.fromJson(Map<String, dynamic>.from(response));
    }
    throw const ParsingException(
      'Unexpected response format from getProductDetails.',
    );
  }
}
