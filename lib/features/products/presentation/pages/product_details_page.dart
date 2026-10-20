import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../domain/entities/product_entity.dart';
import '../cubits/product_details_cubit.dart';
import '../cubits/product_details_state.dart';

class ProductDetailsPage extends StatelessWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailsCubit>(
      create: (_) => sl<ProductDetailsCubit>()..loadProductDetails(productId),
      child: const _ProductDetailsView(),
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Product Details', style: AppTextStyle.appBarTitle),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductDetailsStatus.initial:
            case ProductDetailsStatus.loading:
              return const AppLoadingView(
                message: 'Loading product details...',
              );

            case ProductDetailsStatus.error:
              return AppErrorView(
                title: 'Unable to Load Details',
                message:
                    state.errorMessage ??
                    'Failed to load product details. Please try again.',
                onRetry: () => context.read<ProductDetailsCubit>().retry(),
              );

            case ProductDetailsStatus.success:
              final product = state.product;
              if (product == null) {
                return AppErrorView(
                  title: 'Product Not Found',
                  message: 'The requested product could not be located.',
                  onRetry: () => context.read<ProductDetailsCubit>().retry(),
                );
              }
              return _ProductDetailsContent(product: product);
          }
        },
      ),
    );
  }
}

class _ProductDetailsContent extends StatefulWidget {
  final ProductEntity product;

  const _ProductDetailsContent({required this.product});

  @override
  State<_ProductDetailsContent> createState() => _ProductDetailsContentState();
}

class _ProductDetailsContentState extends State<_ProductDetailsContent> {
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
          // Main Image Showcase
          _ProductImageGallery(
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
                // Category & Brand Tag Row
                Row(
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
                ),

                SizedBox(height: 12.h),

                // Title
                Text(product.title, style: AppTextStyle.headingLarge),

                SizedBox(height: 12.h),

                // Rating & Stock Row
                Row(
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
                ),

                SizedBox(height: 16.h),

                // Price Section
                Container(
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
                ),

                SizedBox(height: 24.h),

                // Description
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

                // Additional Information Card
                _AdditionalInfoCard(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImageGallery extends StatelessWidget {
  final String selectedImageUrl;
  final List<String> images;
  final ValueChanged<String> onSelectImage;

  const _ProductImageGallery({
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

class _AdditionalInfoCard extends StatelessWidget {
  final ProductEntity product;

  const _AdditionalInfoCard({required this.product});

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
