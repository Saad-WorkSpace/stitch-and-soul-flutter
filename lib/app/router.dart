import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/repositories.dart';
import '../features/cart/cart_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/checkout/success_screen.dart';
import '../features/contact/contact_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/measurements/measurement_screen.dart';
import '../features/not_found/not_found_screen.dart';
import '../features/product/product_screen.dart';
import '../features/services/services_screen.dart';
import '../features/story/story_screen.dart';
import '../widgets/site_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) {
          return SiteScaffold(location: state.matchedLocation, child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _fadePage(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) =>
                _fadePage(state, const CatalogScreen()),
            routes: <RouteBase>[
              GoRoute(
                path: 'category/:category',
                pageBuilder: (context, state) {
                  final cat = state.pathParameters['category']!;
                  return _fadePage(state, CatalogScreen(initialCategory: cat));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/product/:slug',
            pageBuilder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return _fadePage(state, ProductScreen(slug: slug));
            },
          ),
          GoRoute(
            path: '/services',
            pageBuilder: (context, state) =>
                _fadePage(state, const ServicesScreen()),
          ),
          GoRoute(
            path: '/story',
            pageBuilder: (context, state) =>
                _fadePage(state, const StoryScreen()),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) =>
                _fadePage(state, const ContactScreen()),
          ),
          GoRoute(
            path: '/measurements/new',
            pageBuilder: (context, state) {
              final productSlug = state.uri.queryParameters['product'];
              return _fadePage(
                state,
                MeasurementScreen(productSlug: productSlug),
              );
            },
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) =>
                _fadePage(state, const FavoritesScreen()),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                _fadePage(state, const CartScreen()),
          ),
          GoRoute(
            path: '/checkout',
            pageBuilder: (context, state) =>
                _fadePage(state, const CheckoutScreen()),
            routes: <RouteBase>[
              GoRoute(
                path: 'success',
                pageBuilder: (context, state) =>
                    _fadePage(state, const CheckoutSuccessScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.012),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

/// Resolve a product by slug, used by screens that need product data.
extension ProductResolver on WidgetRef {
  Product? productBySlug(String slug) {
    return read(productRepositoryProvider).bySlug(slug);
  }
}
