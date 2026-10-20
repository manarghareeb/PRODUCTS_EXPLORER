import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    super.brand,
    required super.thumbnail,
    required super.images,
    super.warrantyInformation,
    super.shippingInformation,
    super.availabilityStatus,
    super.returnPolicy,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId == null || rawId is! num) {
      throw const ParsingException('Product id is missing or invalid.');
    }

    final id = rawId.toInt();
    final title = json['title']?.toString() ?? '';
    final description = json['description']?.toString() ?? '';
    final category = json['category']?.toString() ?? '';

    final rawPrice = json['price'];
    final price = rawPrice is num ? rawPrice.toDouble() : 0.0;

    final rawDiscount = json['discountPercentage'];
    final discountPercentage = rawDiscount is num
        ? rawDiscount.toDouble()
        : 0.0;

    final rawRating = json['rating'];
    final rating = rawRating is num ? rawRating.toDouble() : 0.0;

    final rawStock = json['stock'];
    final stock = rawStock is num ? rawStock.toInt() : 0;

    final brand = json['brand']?.toString();
    final thumbnail = json['thumbnail']?.toString() ?? '';

    final rawImages = json['images'];
    final List<String> images;
    if (rawImages is List) {
      images = rawImages
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList(growable: false);
    } else {
      images = const [];
    }

    final warrantyInformation = json['warrantyInformation']?.toString();
    final shippingInformation = json['shippingInformation']?.toString();
    final availabilityStatus = json['availabilityStatus']?.toString();
    final returnPolicy = json['returnPolicy']?.toString();

    return ProductModel(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      brand: brand,
      thumbnail: thumbnail,
      images: images,
      warrantyInformation: warrantyInformation,
      shippingInformation: shippingInformation,
      availabilityStatus: availabilityStatus,
      returnPolicy: returnPolicy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'returnPolicy': returnPolicy,
    };
  }

  ProductEntity toEntity() => this;
}
