import '../../../../core/error/exceptions.dart';
import '../../domain/entities/products_response_entity.dart';
import 'product_model.dart';

class ProductsResponseModel extends ProductsResponseEntity {
  const ProductsResponseModel({
    required super.products,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    if (rawProducts is! List) {
      throw const ParsingException('Products list is missing or invalid.');
    }

    final products = <ProductModel>[];
    for (final item in rawProducts) {
      if (item is Map<String, dynamic>) {
        products.add(ProductModel.fromJson(item));
      } else if (item is Map) {
        products.add(ProductModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final rawTotal = json['total'];
    final total = rawTotal is num ? rawTotal.toInt() : products.length;

    final rawSkip = json['skip'];
    final skip = rawSkip is num ? rawSkip.toInt() : 0;

    final rawLimit = json['limit'];
    final limit = rawLimit is num ? rawLimit.toInt() : products.length;

    return ProductsResponseModel(
      products: products,
      total: total,
      skip: skip,
      limit: limit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) {
        if (e is ProductModel) return e.toJson();
        return {
          'id': e.id,
          'title': e.title,
          'description': e.description,
          'category': e.category,
          'price': e.price,
          'discountPercentage': e.discountPercentage,
          'rating': e.rating,
          'stock': e.stock,
          'brand': e.brand,
          'thumbnail': e.thumbnail,
          'images': e.images,
          'warrantyInformation': e.warrantyInformation,
          'shippingInformation': e.shippingInformation,
          'availabilityStatus': e.availabilityStatus,
          'returnPolicy': e.returnPolicy,
        };
      }).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
