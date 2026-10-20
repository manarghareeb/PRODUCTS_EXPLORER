import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';
import 'additional_info_card.dart';
import 'category_and_brand_tag_row.dart';
import 'price_section.dart';
import 'product_image_gallery.dart';
import 'rating_and_stock_row.dart';

class ProductDetailsContent extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsContent({super.key, required this.product});

  @override
  State<ProductDetailsContent> createState() => _ProductDetailsContentState();
}

class _ProductDetailsContentState extends State<ProductDetailsContent> {
  late String _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _selectedImageUrl = widget.product.images.isNotEmpty
        ? widget.product.images.first
        : widget.product.thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageGallery(
            selectedImageUrl: _selectedImageUrl,
            images: product.images,
            onSelectImage: (url) {
              setState(() {
                _selectedImageUrl = url;
              });
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryAndBrandTagRow(product: product),
                SizedBox(height: 12.h),
                Text(product.title, style: AppTextStyle.headingLarge),
                SizedBox(height: 12.h),
                RatingAndStockRow(product: product),
                SizedBox(height: 16.h),
                PriceSection(product: product),                
                SizedBox(height: 24.h),
                Text('Description', style: AppTextStyle.headingSmall),
                SizedBox(height: 8.h),
                Text(
                  product.description,
                  style: AppTextStyle.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24.h),
                AdditionalInfoCard(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

