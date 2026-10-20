import '../../../../core/network/api_result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailsUseCase {
  final ProductRepository repository;

  const GetProductDetailsUseCase(this.repository);

  Future<ApiResult<ProductEntity>> call(int id, {dynamic cancelToken}) {
    return repository.getProductDetails(id, cancelToken: cancelToken);
  }
}
