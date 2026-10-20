import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/products_response_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  const ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<ProductsResponseEntity>> getProducts({
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  }) async {
    try {
      final response = await remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on NotFoundException catch (e) {
      return ApiResult.failure(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return ApiResult.failure(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return ApiResult.failure(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return ApiResult.failure(ParsingFailure(e.message));
    } on CancelException catch (e) {
      return ApiResult.failure(CancelFailure(e.message));
    } on ServerException catch (e) {
      return ApiResult.failure(
        ServerFailure(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return ApiResult.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<ProductsResponseEntity>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    dynamic cancelToken,
  }) async {
    try {
      final response = await remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on NotFoundException catch (e) {
      return ApiResult.failure(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return ApiResult.failure(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return ApiResult.failure(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return ApiResult.failure(ParsingFailure(e.message));
    } on CancelException catch (e) {
      return ApiResult.failure(CancelFailure(e.message));
    } on ServerException catch (e) {
      return ApiResult.failure(
        ServerFailure(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return ApiResult.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<ProductEntity>> getProductDetails(
    int id, {
    dynamic cancelToken,
  }) async {
    try {
      final response = await remoteDataSource.getProductDetails(
        id,
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on NotFoundException catch (e) {
      return ApiResult.failure(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return ApiResult.failure(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return ApiResult.failure(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return ApiResult.failure(ParsingFailure(e.message));
    } on CancelException catch (e) {
      return ApiResult.failure(CancelFailure(e.message));
    } on ServerException catch (e) {
      return ApiResult.failure(
        ServerFailure(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return ApiResult.failure(UnknownFailure(e.toString()));
    }
  }
}
