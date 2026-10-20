import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_task/core/error/failures.dart';
import 'package:flutter_task/core/network/api_result.dart';
import 'package:flutter_task/features/products/domain/entities/product_entity.dart';
import 'package:flutter_task/features/products/domain/usecases/get_product_details.dart';
import 'package:flutter_task/features/products/presentation/cubits/product_details_cubit.dart';
import 'package:flutter_task/features/products/presentation/cubits/product_details_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductDetailsUseCase extends Mock
    implements GetProductDetailsUseCase {}

void main() {
  late MockGetProductDetailsUseCase mockGetProductDetailsUseCase;
  late ProductDetailsCubit cubit;

  const testProduct = ProductEntity(
    id: 1,
    title: 'Test Product Details',
    description: 'Detailed description',
    category: 'fragrances',
    price: 49.99,
    discountPercentage: 12.0,
    rating: 4.7,
    stock: 15,
    thumbnail: 'https://example.com/thumb.jpg',
    images: ['https://example.com/img1.jpg'],
    warrantyInformation: '2 year warranty',
    shippingInformation: 'Ships in 2 days',
    availabilityStatus: 'In Stock',
    returnPolicy: '30 days return',
  );

  setUp(() {
    mockGetProductDetailsUseCase = MockGetProductDetailsUseCase();
    cubit = ProductDetailsCubit(
      getProductDetailsUseCase: mockGetProductDetailsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should have initial status and null product', () {
    expect(cubit.state, const ProductDetailsState());
    expect(cubit.state.status, ProductDetailsStatus.initial);
    expect(cubit.state.product, isNull);
  });

  group('loadProductDetails', () {
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'emits [loading, success] when product details are fetched successfully',
      build: () {
        when(
          () => mockGetProductDetailsUseCase(
            1,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const ApiResult.success(testProduct));
        return cubit;
      },
      act: (cubit) => cubit.loadProductDetails(1),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        const ProductDetailsState(
          status: ProductDetailsStatus.success,
          product: testProduct,
        ),
      ],
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'emits [loading, error] when product details fetch fails',
      build: () {
        when(
          () => mockGetProductDetailsUseCase(
            999,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async =>
              const ApiResult.failure(NotFoundFailure('Product not found')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadProductDetails(999),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        const ProductDetailsState(
          status: ProductDetailsStatus.error,
          errorMessage: 'Product not found',
        ),
      ],
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'retries fetching details for the same product id',
      build: () {
        when(
          () => mockGetProductDetailsUseCase(
            1,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const ApiResult.success(testProduct));
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadProductDetails(1);
        cubit.retry();
      },
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        const ProductDetailsState(
          status: ProductDetailsStatus.success,
          product: testProduct,
        ),
        const ProductDetailsState(
          status: ProductDetailsStatus.loading,
          product: testProduct,
        ),
        const ProductDetailsState(
          status: ProductDetailsStatus.success,
          product: testProduct,
        ),
      ],
    );
  });
}
