import 'package:flutter_task/core/di/injection_container.dart';
import 'package:flutter_task/core/network/api_result.dart';
import 'package:flutter_task/features/products/domain/entities/products_response_entity.dart';
import 'package:flutter_task/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_task/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  testWidgets('ProductsExplorerApp pumps without errors', (tester) async {
    final mockRepo = MockProductRepository();
    when(
      () => mockRepo.getProducts(
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => const ApiResult.success(
        ProductsResponseEntity(products: [], total: 0, skip: 0, limit: 20),
      ),
    );

    initDependencies();
    if (sl.isRegistered<ProductRepository>()) {
      sl.unregister<ProductRepository>();
    }
    sl.registerLazySingleton<ProductRepository>(() => mockRepo);

    await tester.pumpWidget(const ProductsExplorerApp());
    await tester.pump();

    expect(find.text('Products Explorer'), findsOneWidget);
  });
}
