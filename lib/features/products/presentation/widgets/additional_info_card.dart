import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/features/products/domain/entities/product_entity.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class AdditionalInfoCard extends StatelessWidget {
  final ProductEntity product;

  const AdditionalInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (product.warrantyInformation != null) {
      rows.add(
        _buildInfoRow(
          Icons.verified_outlined,
          'Warranty',
          product.warrantyInformation!,
        ),
      );
    }

    if (product.shippingInformation != null) {
      if (rows.isNotEmpty) rows.add(const Divider());
      rows.add(
        _buildInfoRow(
          Icons.local_shipping_outlined,
          'Shipping',
          product.shippingInformation!,
        ),
      );
    }

    if (product.returnPolicy != null) {
      if (rows.isNotEmpty) rows.add(const Divider());
      rows.add(
        _buildInfoRow(
          Icons.assignment_return_outlined,
          'Return Policy',
          product.returnPolicy!,
        ),
      );
    }

    if (product.availabilityStatus != null) {
      if (rows.isNotEmpty) rows.add(const Divider());
      rows.add(
        _buildInfoRow(
          Icons.info_outline,
          'Availability',
          product.availabilityStatus!,
        ),
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Information', style: AppTextStyle.headingSmall),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: AppColors.accent),
          SizedBox(width: 12.w),
          Text(label, style: AppTextStyle.bodyMedium),
          const Spacer(),
          Text(value, style: AppTextStyle.titleSmall),
        ],
      ),
    );
  }
}
