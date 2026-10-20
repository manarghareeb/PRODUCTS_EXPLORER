import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../cubits/product_details_cubit.dart';
import '../cubits/product_details_state.dart';
import '../widgets/product_details_content.dart';

class ProductDetailsPage extends StatelessWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

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
              return ProductDetailsContent(product: product);
          }
        },
      ),
    );
  }
}
