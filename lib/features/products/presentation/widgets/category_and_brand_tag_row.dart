import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';

class CategoryAndBrandTagRow extends StatelessWidget {
  const CategoryAndBrandTagRow({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (product.category.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              product.category.toUpperCase(),
              style: AppTextStyle.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (product.brand != null && product.brand!.isNotEmpty) ...[
          SizedBox(width: 8.w),
          Text(
            '•',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            product.brand!,
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}