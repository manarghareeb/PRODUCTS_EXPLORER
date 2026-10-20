import 'package:flutter_task/core/error/exceptions.dart';
import 'package:flutter_task/features/products/data/models/product_model.dart';
import 'package:flutter_task/features/products/data/models/products_response_model.dart';
import 'package:flutter_task/features/products/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel JSON Parsing', () {
    const sampleProductJson = {
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description': 'A popular volumizing mascara.',
      'category': 'beauty',
      'price': 9.99,
      'discountPercentage': 10.5,
      'rating': 4.5,
      'stock': 99,
      'brand': 'Essence',
      'thumbnail': 'https://example.com/thumbnail.jpg',
      'images': [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ],
      'warrantyInformation': '1 week warranty',
      'shippingInformation': 'Ships in 3-5 days',
      'availabilityStatus': 'In Stock',
      'returnPolicy': 'No return policy',
    };

    test(
      'should correctly parse a complete product JSON into ProductModel',
      () {
        final model = ProductModel.fromJson(sampleProductJson);

        expect(model.id, 1);
        expect(model.title, 'Essence Mascara Lash Princess');
        expect(model.description, 'A popular volumizing mascara.');
        expect(model.category, 'beauty');
        expect(model.price, 9.99);
        expect(model.discountPercentage, 10.5);
        expect(model.rating, 4.5);
        expect(model.stock, 99);
        expect(model.brand, 'Essence');
        expect(model.thumbnail, 'https://example.com/thumbnail.jpg');
        expect(model.images.length, 2);
        expect(model.warrantyInformation, '1 week warranty');
        expect(model.shippingInformation, 'Ships in 3-5 days');
        expect(model.availabilityStatus, 'In Stock');
        expect(model.returnPolicy, 'No return policy');
        expect(model, isA<ProductEntity>());
      },
    );

    test('should safely handle missing and unexpected optional fields', () {
      final jsonWithMissingFields = {
        'id': 2,
        'title': 'Minimal Product',
        // missing description, category, brand, images, warranty, etc.
      };

      final model = ProductModel.fromJson(jsonWithMissingFields);

      expect(model.id, 2);
      expect(model.title, 'Minimal Product');
      expect(model.description, '');
      expect(model.category, '');
      expect(model.brand, isNull);
      expect(model.price, 0.0);
      expect(model.discountPercentage, 0.0);
      expect(model.rating, 0.0);
      expect(model.stock, 0);
      expect(model.thumbnail, '');
      expect(model.images, isEmpty);
      expect(model.warrantyInformation, isNull);
      expect(model.shippingInformation, isNull);
      expect(model.availabilityStatus, isNull);
      expect(model.returnPolicy, isNull);
    });

    test(
      'should throw ParsingException when product id is missing or null',
      () {
        final jsonMissingId = {'title': 'No ID Product', 'price': 10.0};

        expect(
          () => ProductModel.fromJson(jsonMissingId),
          throwsA(isA<ParsingException>()),
        );
      },
    );

    test('should calculate discountedPrice correctly', () {
      const model = ProductModel(
        id: 1,
        title: 'Discounted Item',
        description: '',
        category: '',
        price: 100.0,
        discountPercentage: 20.0,
        rating: 4.0,
        stock: 10,
        thumbnail: '',
        images: [],
      );

      expect(model.discountedPrice, closeTo(80.0, 0.001));
    });

    test('should convert ProductModel to JSON map correctly', () {
      final model = ProductModel.fromJson(sampleProductJson);
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Essence Mascara Lash Princess');
      expect(json['price'], 9.99);
      expect(json['brand'], 'Essence');
    });
  });

  group('ProductsResponseModel JSON Parsing', () {
    test('should parse list of products, total, skip, and limit correctly', () {
      final responseJson = {
        'products': [
          {'id': 1, 'title': 'Product 1', 'price': 10.0},
          {'id': 2, 'title': 'Product 2', 'price': 20.0},
        ],
        'total': 50,
        'skip': 0,
        'limit': 2,
      };

      final responseModel = ProductsResponseModel.fromJson(responseJson);

      expect(responseModel.products.length, 2);
      expect(responseModel.total, 50);
      expect(responseModel.skip, 0);
      expect(responseModel.limit, 2);
      expect(responseModel.hasMore, isTrue);
    });

    test(
      'should throw ParsingException when products list is missing or invalid',
      () {
        final invalidJson = {'products': 'not a list', 'total': 0};

        expect(
          () => ProductsResponseModel.fromJson(invalidJson),
          throwsA(isA<ParsingException>()),
        );
      },
    );
  });
}
