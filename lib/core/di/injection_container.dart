import 'package:get_it/get_it.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_product_details.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/search_products.dart';
import '../../features/products/presentation/cubits/product_details_cubit.dart';
import '../../features/products/presentation/cubits/products_cubit.dart';
import '../network/api_consumer.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<ApiConsumer>(() => sl<DioClient>());

  // Data Sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiConsumer: sl<ApiConsumer>()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () =>
        ProductRepositoryImpl(remoteDataSource: sl<ProductRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<SearchProductsUseCase>(
    () => SearchProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetProductDetailsUseCase>(
    () => GetProductDetailsUseCase(sl<ProductRepository>()),
  );

  // Cubits
  sl.registerFactory<ProductsCubit>(
    () => ProductsCubit(
      getProductsUseCase: sl<GetProductsUseCase>(),
      searchProductsUseCase: sl<SearchProductsUseCase>(),
    ),
  );
  sl.registerFactory<ProductDetailsCubit>(
    () => ProductDetailsCubit(
      getProductDetailsUseCase: sl<GetProductDetailsUseCase>(),
    ),
  );
}
