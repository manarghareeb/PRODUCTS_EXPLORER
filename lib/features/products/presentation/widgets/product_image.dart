import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class ProductImage extends StatelessWidget {
  final String thumbnailUrl;
  final double discountPercentage;
  final double rating;

  const ProductImage({super.key, 
    required this.thumbnailUrl,
    required this.discountPercentage,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(11.r)),
            child: CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.imagePlaceholder,
                child: Center(
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.imagePlaceholder,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted,
                    size: 28.r,
                  ),
                ),
              ),
            ),
          ),
          if (discountPercentage > 0)
            Positioned(
              top: 8.r,
              left: 8.r,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.discountBadgeBackground,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '-${discountPercentage.toStringAsFixed(0)}%',
                  style: AppTextStyle.badgeText,
                ),
              ),
            ),
          Positioned(
            top: 8.r,
            right: 8.r,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6.r),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14.r,
                    color: AppColors.starRating,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyle.ratingText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
