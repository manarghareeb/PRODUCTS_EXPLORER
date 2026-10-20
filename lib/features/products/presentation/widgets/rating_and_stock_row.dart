import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';

class RatingAndStockRow extends StatelessWidget {
  const RatingAndStockRow({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: 16.r,
                color: AppColors.starRating,
              ),
              SizedBox(width: 4.w),
              Text(
                product.rating.toStringAsFixed(1),
                style: AppTextStyle.ratingText,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: product.stock > 0
                ? AppColors.successLight
                : AppColors.errorLight,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            product.stock > 0
                ? (product.stock < 10
                      ? 'Only ${product.stock} in stock'
                      : 'In Stock (${product.stock})')
                : 'Out of Stock',
            style: AppTextStyle.labelSmall.copyWith(
              color: product.stock > 0
                  ? AppColors.successText
                  : AppColors.errorText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
