import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../cubits/products_state.dart';

class ProductsPaginationLoader extends StatelessWidget {
  final PaginationStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  const ProductsPaginationLoader({
    super.key,
    required this.status,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (status == PaginationStatus.loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              SizedBox(width: 12.w),
              Text('Loading more products...', style: AppTextStyle.bodySmall),
            ],
          ),
        ),
      );
    }

    if (status == PaginationStatus.error) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 20.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  errorMessage ?? 'Failed to load more products.',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.errorText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorText,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 14.r),
                    SizedBox(width: 4.w),
                    Text(
                      'Retry',
                      style: AppTextStyle.labelMedium.copyWith(
                        color: AppColors.errorText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(height: 16.h);
  }
}
