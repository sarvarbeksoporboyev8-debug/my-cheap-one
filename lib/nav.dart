import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sellingapp/features/discover/presentation/pages/discover_page.dart';
import 'package:sellingapp/features/shopfront/presentation/pages/shopfront_page.dart';
import 'package:sellingapp/features/products/presentation/pages/product_detail_page.dart';
import 'package:sellingapp/features/cart/presentation/pages/cart_page.dart';
import 'package:sellingapp/features/checkout/presentation/pages/checkout_flow_page.dart';
import 'package:sellingapp/features/checkout/presentation/pages/order_confirmation_page.dart';
import 'package:sellingapp/features/account/presentation/pages/admin_settings_page.dart';
import 'package:sellingapp/features/account/presentation/pages/account_page.dart';
import 'package:sellingapp/features/discover/presentation/pages/producer_detail_page.dart';
import 'package:sellingapp/features/account/presentation/pages/favorites_page.dart';
import 'package:sellingapp/features/account/presentation/pages/orders_page.dart';
import 'package:sellingapp/features/account/presentation/pages/profile_page.dart';
import 'package:sellingapp/features/account/presentation/pages/settings_page.dart';
import 'package:sellingapp/nav_shell.dart';
import 'package:sellingapp/features/map/presentation/pages/map_page.dart';

/// GoRouter configuration for app navigation
///
/// This uses go_router for declarative routing, which provides:
/// - Type-safe navigation
/// - Deep linking support (web URLs, app links)
/// - Easy route parameters
/// - Navigation guards and redirects
///
/// To add a new route:
/// 1. Add a route constant to AppRoutes below
/// 2. Add a GoRoute to the routes list
/// 3. Navigate using context.go() or context.push()
/// 4. Use context.pop() to go back.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.discover,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => NavShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.discover,
              pageBuilder: (context, state) => const NoTransitionPage(child: DiscoverPage()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.map,
              pageBuilder: (context, state) => NoTransitionPage(child: MapPage()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.cart,
              pageBuilder: (context, state) => const NoTransitionPage(child: CartPage()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.account,
              pageBuilder: (context, state) => const NoTransitionPage(child: AccountPage()),
              routes: [
                GoRoute(
                  path: 'admin',
                  pageBuilder: (context, state) => const NoTransitionPage(child: AdminSettingsPage()),
                ),
                GoRoute(
                  path: 'favorites',
                  pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesPage()),
                ),
                GoRoute(
                  path: 'orders',
                  pageBuilder: (context, state) => const NoTransitionPage(child: OrdersPage()),
                ),
                GoRoute(
                  path: 'profile',
                  pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
                ),
                GoRoute(
                  path: 'settings',
                  pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.shopfront,
        name: 'shopfront',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(child: ShopfrontPage(enterpriseId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.producer,
        name: 'producer',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(child: ProducerDetailPage(id: id));
        },
      ),
      GoRoute(
        path: AppRoutes.product,
        name: 'product',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(child: ProductDetailPage(productId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        pageBuilder: (context, state) => const NoTransitionPage(child: CheckoutFlowPage()),
      ),
      GoRoute(
        path: AppRoutes.confirmation,
        name: 'confirmation',
        pageBuilder: (context, state) => const NoTransitionPage(child: OrderConfirmationPage()),
      ),
    ],
  );
}

/// Route path constants
/// Use these instead of hard-coding route strings
class AppRoutes {
  static const String discover = '/';
  static const String map = '/map';
  static const String shopfront = '/shops/:id';
  static const String producer = '/producers/:id';
  static const String product = '/products/:id';
  static const String cart = '/cart';
  static const String account = '/account';
  static const String checkout = '/checkout';
  static const String confirmation = '/confirmation';
}
