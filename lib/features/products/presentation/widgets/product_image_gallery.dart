import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class ProductImageGallery extends StatelessWidget {
  final String selectedImageUrl;
  final List<String> images;
  final ValueChanged<String> onSelectImage;

  const ProductImageGallery({super.key, 
    required this.selectedImageUrl,
    required this.images,
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: CachedNetworkImage(
              imageUrl: selectedImageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: AppColors.imagePlaceholder,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.imagePlaceholder,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted,
                    size: 40.r,
                  ),
                ),
              ),
            ),
          ),

          if (images.length > 1) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 56.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  final isSelected = imageUrl == selectedImageUrl;

                  return GestureDetector(
                    onTap: () => onSelectImage(imageUrl),
                    child: Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.r),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.imagePlaceholder),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image_outlined,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}