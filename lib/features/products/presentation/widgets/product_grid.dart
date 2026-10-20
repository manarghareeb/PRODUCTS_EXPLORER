import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';
import '../cubits/products_state.dart';
import 'product_card.dart';
import 'products_pagination_loader.dart';

/// Responsive grid displaying products with infinite scroll pagination and pull-to-refresh.
class ProductGrid extends StatefulWidget {
  final List<ProductEntity> products;
  final PaginationStatus paginationStatus;
  final String? paginationErrorMessage;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final VoidCallback onRetryPagination;
  final ValueChanged<ProductEntity> onProductTap;
  final Future<void> Function() onRefresh;

  const ProductGrid({
    super.key,
    required this.products,
    required this.paginationStatus,
    this.paginationErrorMessage,
    required this.hasMore,
    required this.onLoadMore,
    required this.onRetryPagination,
    required this.onProductTap,
    required this.onRefresh,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger next page when user scrolls within 300px of bottom
    const threshold = 300.0;

    if (maxScroll - currentScroll <= threshold) {
      if (widget.hasMore &&
          widget.paginationStatus != PaginationStatus.loading) {
        widget.onLoadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final int crossAxisCount;
        if (screenWidth >= 900) {
          crossAxisCount = 4;
        } else if (screenWidth >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = widget.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => widget.onProductTap(product),
                    );
                  }, childCount: widget.products.length),
                ),
              ),

              // Bottom pagination loader or error retry
              SliverToBoxAdapter(
                child: ProductsPaginationLoader(
                  status: widget.paginationStatus,
                  errorMessage: widget.paginationErrorMessage,
                  onRetry: widget.onRetryPagination,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
