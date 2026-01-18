import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sellingapp/features/discover/presentation/pages/discover_page.dart';
import 'package:sellingapp/features/shopfront/presentation/pages/shopfront_page.dart';
import 'package:sellingapp/features/products/presentation/pages/product_detail_page.dart';
import 'package:sellingapp/features/cart/presentation/pages/cart_page.dart';
import 'package:sellingapp/features/checkout/presentation/pages/checkout_flow_page.dart';
import 'package:sellingapp/features/checkout/presentation/pages/order_confirmation_page.dart';
import 'package:sellingapp/features/account/presentation/pages/admin_mode_page.dart';
import 'package:sellingapp/features/account/presentation/pages/account_page.dart';
import 'package:sellingapp/features/discover/presentation/pages/producer_detail_page.dart';
import 'package:sellingapp/features/account/presentation/pages/favorites_page.dart';
import 'package:sellingapp/features/account/presentation/pages/orders_or_reservations_page.dart';
import 'package:sellingapp/features/account/presentation/pages/profile_page.dart';
import 'package:sellingapp/features/account/presentation/pages/settings_page.dart';
import 'package:sellingapp/features/account/presentation/pages/my_listings_page.dart';
import 'package:sellingapp/features/account/presentation/pages/offers_page.dart';
import 'package:sellingapp/features/account/presentation/pages/location_settings_page.dart';
import 'package:sellingapp/features/account/presentation/pages/notification_settings_page.dart';
import 'package:sellingapp/features/account/presentation/pages/appearance_page.dart';
import 'package:sellingapp/features/account/presentation/pages/support_page.dart';
import 'package:sellingapp/features/account/presentation/pages/about_page.dart';
import 'package:sellingapp/features/account/presentation/pages/login_page.dart';
import 'package:sellingapp/nav_shell.dart';
import 'package:sellingapp/features/map/presentation/pages/map_page.dart';
import 'package:sellingapp/screens/home/home_screen_v2.dart';
import 'package:sellingapp/screens/category/category_browse_screen.dart';
import 'package:sellingapp/screens/category/urgency_browse_screen.dart';
import 'package:sellingapp/features/delivery/presentation/pages/searching_driver_page.dart';
import 'package:sellingapp/features/delivery/presentation/pages/delivery_tracking_page.dart';
import 'package:sellingapp/features/delivery/presentation/pages/driver_mode_page.dart';
import 'package:sellingapp/features/delivery/presentation/pages/driver_settings_page.dart';
import 'package:sellingapp/features/delivery/presentation/pages/driver_placeholder_pages.dart';

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
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.discover,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => NavShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.discover,
              pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreenV2()),
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
                  pageBuilder: (context, state) => const NoTransitionPage(child: AdminModePage()),
                ),
                GoRoute(
                  path: 'favorites',
                  pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesPage()),
                ),
                GoRoute(
                  path: 'orders',
                  pageBuilder: (context, state) => const NoTransitionPage(child: OrdersOrReservationsPage()),
                ),
                GoRoute(
                  path: 'profile',
                  pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
                ),
                GoRoute(
                  path: 'settings',
                  pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
                ),
                GoRoute(
                  path: 'my-listings',
                  pageBuilder: (context, state) => const NoTransitionPage(child: MyListingsPage()),
                ),
                GoRoute(
                  path: 'offers',
                  pageBuilder: (context, state) => const NoTransitionPage(child: OffersPage()),
                ),
                GoRoute(
                  path: 'location',
                  pageBuilder: (context, state) => const NoTransitionPage(child: LocationSettingsPage()),
                ),
                GoRoute(
                  path: 'notifications',
                  pageBuilder: (context, state) => const NoTransitionPage(child: NotificationSettingsPage()),
                ),
                GoRoute(
                  path: 'appearance',
                  pageBuilder: (context, state) => const NoTransitionPage(child: AppearancePage()),
                ),
                GoRoute(
                  path: 'support',
                  pageBuilder: (context, state) => const NoTransitionPage(child: SupportPage()),
                ),
                GoRoute(
                  path: 'about',
                  pageBuilder: (context, state) => const NoTransitionPage(child: AboutPage()),
                ),
              ],
            ),
          ]),
        ],
      ),
      // Category browse screen – outside the shell so it appears full-screen.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.category,
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          final title = (state.extra is Map && (state.extra as Map).containsKey('title')) ? (state.extra as Map)['title'] as String? : null;
          return NoTransitionPage(child: CategoryBrowseScreen(slug: slug, title: title));
        },
      ),
      // Urgency browse screen – outside the shell, full-screen without bottom nav
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.urgency,
        pageBuilder: (context, state) {
          final window = state.pathParameters['window']!; // e.g., 2h, 8h
          final title = (state.extra is Map && (state.extra as Map).containsKey('title')) ? (state.extra as Map)['title'] as String? : null;
          return NoTransitionPage(
            child: UrgencyBrowseScreen(window: window, title: title),
          );
        },
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
      // Login outside the shell
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.login,
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
      ),
      // Delivery routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.searchingDriver,
        pageBuilder: (context, state) {
          final deliveryId = state.pathParameters['deliveryId']!;
          return NoTransitionPage(child: SearchingDriverPage(deliveryId: deliveryId));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.deliveryTracking,
        pageBuilder: (context, state) {
          final deliveryId = state.pathParameters['deliveryId']!;
          return NoTransitionPage(child: DeliveryTrackingPage(deliveryId: deliveryId));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.driverMode,
        pageBuilder: (context, state) => const NoTransitionPage(child: DriverModePage()),
      ),
      // Driver settings and sub-pages
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.driverSettings,
        pageBuilder: (context, state) => const NoTransitionPage(child: DriverSettingsPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.driverProfile,
        pageBuilder: (context, state) => const NoTransitionPage(child: DriverProfilePage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.driverVehicle,
        pageBuilder: (context, state) => const NoTransitionPage(child: DriverVehiclePage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.driverDocuments,
        pageBuilder: (context, state) => const NoTransitionPage(child: DriverDocumentsPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.driverPayout,
        pageBuilder: (context, state) => const NoTransitionPage(child: DriverPayoutPage()),
      ),
    ],
  );
}

/// Route path constants
/// Use these instead of hard-coding route strings
class AppRoutes {
  static const String discover = '/';
  static const String map = '/map';
  static const String category = '/category/:slug';
  static const String urgency = '/urgency/:window';
  static const String shopfront = '/shops/:id';
  static const String producer = '/producers/:id';
  static const String product = '/products/:id';
  static const String cart = '/cart';
  static const String account = '/account';
  static const String checkout = '/checkout';
  static const String confirmation = '/confirmation';
  static const String login = '/login';
  
  // Delivery routes
  static const String searchingDriver = '/delivery/searching/:deliveryId';
  static const String deliveryTracking = '/delivery/tracking/:deliveryId';
  static const String driverMode = '/driver-mode';
  static const String driverSettings = '/driver/settings';
  static const String driverProfile = '/driver/profile';
  static const String driverVehicle = '/driver/vehicle';
  static const String driverDocuments = '/driver/documents';
  static const String driverPayout = '/driver/payout';

  static String categoryBrowsePath(String slug) => '/category/$slug';
  static String urgencyBrowsePath(String window) => '/urgency/$window';
  static String searchingDriverPath(String deliveryId) => '/delivery/searching/$deliveryId';
  static String deliveryTrackingPath(String deliveryId) => '/delivery/tracking/$deliveryId';
}
