import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';

class PriceSection extends StatelessWidget {
  const PriceSection({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price', style: AppTextStyle.bodySmall),
              SizedBox(height: 2.h),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: AppTextStyle.priceLarge,
              ),
            ],
          ),
          const Spacer(),
          if (product.discountPercentage > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.discountBadgeBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Save ${product.discountPercentage.toStringAsFixed(0)}%',
                style: AppTextStyle.badgeText,
              ),
            ),
        ],
      ),
    );
  }
}
