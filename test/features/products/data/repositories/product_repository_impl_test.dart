import 'package:flutter_task/core/error/exceptions.dart';
import 'package:flutter_task/core/error/failures.dart';
import 'package:flutter_task/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_task/features/products/data/models/product_model.dart';
import 'package:flutter_task/features/products/data/models/products_response_model.dart';
import 'package:flutter_task/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const testProduct = ProductModel(
    id: 1,
    title: 'Test Product',
    description: 'Test Description',
    category: 'electronics',
    price: 99.99,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 5,
    thumbnail: 'https://example.com/thumb.jpg',
    images: ['https://example.com/img1.jpg'],
  );

  const testProductsResponse = ProductsResponseModel(
    products: [testProduct],
    total: 1,
    skip: 0,
    limit: 20,
  );

  group('getProducts', () {
    test(
      'should return ApiSuccess with ProductsResponseEntity when remote call is successful',
      () async {
        when(
          () => mockRemoteDataSource.getProducts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => testProductsResponse);

        final result = await repository.getProducts(limit: 20, skip: 0);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.products.length, 1);
        expect(result.dataOrNull?.products.first.id, 1);
        verify(
          () => mockRemoteDataSource.getProducts(limit: 20, skip: 0),
        ).called(1);
      },
    );

    test(
      'should return NetworkFailure when remote call throws NetworkException',
      () async {
        when(
          () => mockRemoteDataSource.getProducts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(const NetworkException('No connection'));

        final result = await repository.getProducts(limit: 20, skip: 0);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<NetworkFailure>());
        expect(result.failureOrNull?.message, 'No connection');
      },
    );

    test(
      'should return ServerFailure when remote call throws ServerException',
      () async {
        when(
          () => mockRemoteDataSource.getProducts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          const ServerException('Internal Server Error', statusCode: 500),
        );

        final result = await repository.getProducts(limit: 20, skip: 0);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ServerFailure>());
        final failure = result.failureOrNull as ServerFailure;
        expect(failure.statusCode, 500);
      },
    );

    test(
      'should return TimeoutFailure when remote call throws TimeoutException',
      () async {
        when(
          () => mockRemoteDataSource.getProducts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(const TimeoutException('Timeout occurred'));

        final result = await repository.getProducts(limit: 20, skip: 0);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<TimeoutFailure>());
      },
    );

    test(
      'should return ParsingFailure when remote call throws ParsingException',
      () async {
        when(
          () => mockRemoteDataSource.getProducts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(const ParsingException('Malformed JSON'));

        final result = await repository.getProducts(limit: 20, skip: 0);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ParsingFailure>());
      },
    );
  });

  group('searchProducts', () {
    test(
      'should return ApiSuccess with searched products when successful',
      () async {
        when(
          () => mockRemoteDataSource.searchProducts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => testProductsResponse);

        final result = await repository.searchProducts(
          query: 'phone',
          limit: 20,
          skip: 0,
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.products.length, 1);
        verify(
          () => mockRemoteDataSource.searchProducts(
            query: 'phone',
            limit: 20,
            skip: 0,
          ),
        ).called(1);
      },
    );
  });

  group('getProductDetails', () {
    test(
      'should return ApiSuccess with ProductEntity when successful',
      () async {
        when(
          () => mockRemoteDataSource.getProductDetails(
            any(),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => testProduct);

        final result = await repository.getProductDetails(1);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.id, 1);
        verify(() => mockRemoteDataSource.getProductDetails(1)).called(1);
      },
    );

    test(
      'should return NotFoundFailure when product id is not found',
      () async {
        when(
          () => mockRemoteDataSource.getProductDetails(
            any(),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(const NotFoundException('Product not found'));

        final result = await repository.getProductDetails(999);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<NotFoundFailure>());
      },
    );
  });
}
