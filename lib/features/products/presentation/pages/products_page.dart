import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../cubits/products_cubit.dart';
import '../cubits/products_state.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_search_field.dart';
import '../widgets/products_skeleton_grid.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final currentQuery = context.read<ProductsCubit>().state.searchQuery;
    _searchController = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Products Explorer', style: AppTextStyle.appBarTitle),
        elevation: 0,
        backgroundColor: AppColors.surface,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(68.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
            child: ProductSearchField(
              controller: _searchController,
              onChanged: (query) {
                context.read<ProductsCubit>().onSearchChanged(query);
              },
              onClear: () {
                context.read<ProductsCubit>().clearSearch();
              },
              onSubmitted: (query) {
                context.read<ProductsCubit>().searchNow(query);
              },
            ),
          ),
        ),
      ),
      body: const _ProductsBodySection(),
    );
  }
}

class _ProductsBodySection extends StatelessWidget {
  const _ProductsBodySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final cubit = context.read<ProductsCubit>();

        switch (state.status) {
          case ProductsStatus.initial:
          case ProductsStatus.loading:
            return const ProductsSkeletonGrid();

          case ProductsStatus.error:
            return AppErrorView(
              message:
                  state.errorMessage ??
                  'Failed to load products. Please check your connection.',
              onRetry: () => cubit.retry(),
            );

          case ProductsStatus.empty:
            if (state.isSearching) {
              return AppEmptyView(
                title: 'No Products Found',
                message:
                    'No products match "${state.searchQuery}". Try searching for something else.',
                icon: Icons.search_off_rounded,
                actionText: 'Clear Search',
                onAction: () => cubit.clearSearch(),
              );
            }
            return AppEmptyView(
              title: 'No Products Available',
              message:
                  'The catalog is currently empty. Please check back later.',
              icon: Icons.inventory_2_outlined,
              actionText: 'Refresh',
              onAction: () => cubit.loadProducts(),
            );

          case ProductsStatus.success:
            return ProductGrid(
              products: state.products,
              paginationStatus: state.paginationStatus,
              paginationErrorMessage: state.paginationErrorMessage,
              hasMore: state.hasMore,
              onLoadMore: () => cubit.loadMoreProducts(),
              onRetryPagination: () => cubit.retryPagination(),
              onProductTap: (product) {
                context.push('/products/${product.id}');
              },
              onRefresh: () => cubit.loadProducts(isRefresh: true),
            );
        }
      },
    );
  }
}
