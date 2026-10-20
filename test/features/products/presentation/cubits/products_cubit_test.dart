import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_task/core/error/failures.dart';
import 'package:flutter_task/core/network/api_result.dart';
import 'package:flutter_task/features/products/domain/entities/product_entity.dart';
import 'package:flutter_task/features/products/domain/entities/products_response_entity.dart';
import 'package:flutter_task/features/products/domain/usecases/get_products.dart';
import 'package:flutter_task/features/products/domain/usecases/search_products.dart';
import 'package:flutter_task/features/products/presentation/cubits/products_cubit.dart';
import 'package:flutter_task/features/products/presentation/cubits/products_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockSearchProductsUseCase mockSearchProductsUseCase;
  late ProductsCubit cubit;

  const testProduct1 = ProductEntity(
    id: 1,
    title: 'Product 1',
    description: 'Description 1',
    category: 'beauty',
    price: 10.0,
    discountPercentage: 5.0,
    rating: 4.0,
    stock: 20,
    thumbnail: 'https://example.com/p1.jpg',
    images: ['https://example.com/p1.jpg'],
  );

  const testProduct2 = ProductEntity(
    id: 2,
    title: 'Product 2',
    description: 'Description 2',
    category: 'electronics',
    price: 50.0,
    discountPercentage: 0.0,
    rating: 4.8,
    stock: 10,
    thumbnail: 'https://example.com/p2.jpg',
    images: ['https://example.com/p2.jpg'],
  );

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockSearchProductsUseCase = MockSearchProductsUseCase();
    cubit = ProductsCubit(
      getProductsUseCase: mockGetProductsUseCase,
      searchProductsUseCase: mockSearchProductsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be ProductsState with initial status', () {
    expect(cubit.state, const ProductsState());
    expect(cubit.state.status, ProductsStatus.initial);
    expect(cubit.state.products, isEmpty);
    expect(cubit.state.hasMore, isTrue);
  });

  group('Initial Product Loading', () {
    blocTest<ProductsCubit, ProductsState>(
      'emits [loading, success] when getProductsUseCase succeeds',
      build: () {
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => const ApiResult.success(
            ProductsResponseEntity(
              products: [testProduct1],
              total: 1,
              skip: 0,
              limit: 20,
            ),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.loading,
          paginationStatus: PaginationStatus.idle,
        ),
        const ProductsState(
          status: ProductsStatus.success,
          products: [testProduct1],
          total: 1,
          skip: 0,
          hasMore: false,
          paginationStatus: PaginationStatus.idle,
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emits [loading, error] when getProductsUseCase fails',
      build: () {
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async =>
              const ApiResult.failure(NetworkFailure('Connection failed')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.loading,
          paginationStatus: PaginationStatus.idle,
        ),
        const ProductsState(
          status: ProductsStatus.error,
          errorMessage: 'Connection failed',
        ),
      ],
    );
  });

  group('Search Products', () {
    blocTest<ProductsCubit, ProductsState>(
      'emits [loading, success] on successful searchNow query',
      build: () {
        when(
          () => mockSearchProductsUseCase(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => const ApiResult.success(
            ProductsResponseEntity(
              products: [testProduct1],
              total: 1,
              skip: 0,
              limit: 20,
            ),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.searchNow('mascara'),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.loading,
          searchQuery: 'mascara',
          paginationStatus: PaginationStatus.idle,
        ),
        const ProductsState(
          status: ProductsStatus.success,
          searchQuery: 'mascara',
          products: [testProduct1],
          total: 1,
          skip: 0,
          hasMore: false,
          paginationStatus: PaginationStatus.idle,
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emits [loading, empty] when search returns zero products',
      build: () {
        when(
          () => mockSearchProductsUseCase(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => const ApiResult.success(
            ProductsResponseEntity(products: [], total: 0, skip: 0, limit: 20),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.searchNow('nonexistent_item'),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.loading,
          searchQuery: 'nonexistent_item',
          paginationStatus: PaginationStatus.idle,
        ),
        const ProductsState(
          status: ProductsStatus.empty,
          searchQuery: 'nonexistent_item',
          products: [],
          total: 0,
          skip: 0,
          hasMore: false,
          paginationStatus: PaginationStatus.idle,
        ),
      ],
    );
  });

  group('Pagination', () {
    blocTest<ProductsCubit, ProductsState>(
      'appends products and updates skip & hasMore on pagination success',
      seed: () => const ProductsState(
        status: ProductsStatus.success,
        products: [testProduct1],
        total: 2,
        skip: 0,
        hasMore: true,
      ),
      build: () {
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => const ApiResult.success(
            ProductsResponseEntity(
              products: [testProduct2],
              total: 2,
              skip: 1,
              limit: 20,
            ),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadMoreProducts(),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.success,
          products: [testProduct1],
          total: 2,
          skip: 0,
          hasMore: true,
          paginationStatus: PaginationStatus.loading,
        ),
        const ProductsState(
          status: ProductsStatus.success,
          products: [testProduct1, testProduct2],
          total: 2,
          skip: 1,
          hasMore: false,
          paginationStatus: PaginationStatus.idle,
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'preserves already loaded products on pagination failure',
      seed: () => const ProductsState(
        status: ProductsStatus.success,
        products: [testProduct1],
        total: 10,
        skip: 0,
        hasMore: true,
      ),
      build: () {
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async =>
              const ApiResult.failure(NetworkFailure('Pagination timeout')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadMoreProducts(),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.success,
          products: [testProduct1],
          total: 10,
          skip: 0,
          hasMore: true,
          paginationStatus: PaginationStatus.loading,
        ),
        const ProductsState(
          status: ProductsStatus.success,
          products: [testProduct1],
          total: 10,
          skip: 0,
          hasMore: true,
          paginationStatus: PaginationStatus.error,
          paginationErrorMessage: 'Pagination timeout',
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'prevents duplicate concurrent pagination requests when already loading',
      seed: () => const ProductsState(
        status: ProductsStatus.success,
        paginationStatus: PaginationStatus.loading,
        products: [testProduct1],
        total: 10,
        hasMore: true,
      ),
      build: () => cubit,
      act: (cubit) => cubit.loadMoreProducts(),
      expect: () => [], // No new states emitted
      verify: (_) {
        verifyNever(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        );
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'does not load more products when hasMore is false',
      seed: () => const ProductsState(
        status: ProductsStatus.success,
        paginationStatus: PaginationStatus.idle,
        products: [testProduct1],
        total: 1,
        hasMore: false,
      ),
      build: () => cubit,
      act: (cubit) => cubit.loadMoreProducts(),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        );
      },
    );
  });

  group('Stale Search Results and Cancellation', () {
    test(
      'ignores stale response when a newer search query completes first',
      () async {
        final slowSearchCompleter =
            Completer<ApiResult<ProductsResponseEntity>>();
        final fastSearchCompleter =
            Completer<ApiResult<ProductsResponseEntity>>();

        when(
          () => mockSearchProductsUseCase(
            query: 'slow',
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) => slowSearchCompleter.future);

        when(
          () => mockSearchProductsUseCase(
            query: 'fast',
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) => fastSearchCompleter.future);

        // Start slow search
        cubit.searchNow('slow');
        expect(cubit.state.searchQuery, 'slow');
        expect(cubit.state.status, ProductsStatus.loading);

        // Immediately start fast search
        cubit.searchNow('fast');
        expect(cubit.state.searchQuery, 'fast');

        // Resolve fast search first
        fastSearchCompleter.complete(
          const ApiResult.success(
            ProductsResponseEntity(
              products: [testProduct2],
              total: 1,
              skip: 0,
              limit: 20,
            ),
          ),
        );
        await pumpEventQueue();

        expect(cubit.state.products, [testProduct2]);
        expect(cubit.state.searchQuery, 'fast');

        // Resolve old slow search later
        slowSearchCompleter.complete(
          const ApiResult.success(
            ProductsResponseEntity(
              products: [testProduct1],
              total: 1,
              skip: 0,
              limit: 20,
            ),
          ),
        );
        await pumpEventQueue();

        // Ensure stale search did NOT overwrite the newer result
        expect(cubit.state.products, [testProduct2]);
        expect(cubit.state.searchQuery, 'fast');
      },
    );
  });
}
