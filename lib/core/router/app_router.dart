import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/products/presentation/cubits/products_cubit.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../di/injection_container.dart';
import '../widgets/app_error_view.dart';

class AppRoutes {
  static const String products = '/';
  static const String productDetails = '/products/:id';

  static String productDetailsPath(int id) => '/products/$id';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.products,
    routes: [
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) {
          return BlocProvider<ProductsCubit>(
            create: (_) => sl<ProductsCubit>()..loadProducts(),
            child: const ProductsPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) {
          final idParam = state.pathParameters['id'];
          final productId = int.tryParse(idParam ?? '');

          if (productId == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: AppErrorView(
                title: 'Invalid Product ID',
                message: 'The requested product ID is invalid.',
                onRetry: () => context.pop(),
                retryText: 'Go Back',
              ),
            );
          }
          return ProductDetailsPage(productId: productId);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: AppErrorView(
          title: '404 - Not Found',
          message: 'The page you requested does not exist.',
          onRetry: () => context.go(AppRoutes.products),
          retryText: 'Go to Products',
        ),
      );
    },
  );
}
