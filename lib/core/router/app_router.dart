import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/scanner/scanner_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/visitors/visitor_details_screen.dart';
import '../../features/visitors/visitor_form_screen.dart';
import '../../features/visitors/visitor_list_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      // Tabs. A plain ShellRoute only builds the active tab, so the camera
      // is released when leaving the Scan tab.
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) =>
            MainShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/visitors',
            builder: (_, _) => const VisitorListScreen(),
          ),
          GoRoute(path: '/scan', builder: (_, _) => const ScannerScreen()),
        ],
      ),
      // Full-screen routes above the bottom navigation.
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const VisitorFormScreen(),
      ),
      GoRoute(
        path: '/visitors/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) =>
            VisitorDetailsScreen(visitorId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/visitors/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => VisitorFormScreen(visitorId: s.pathParameters['id']),
      ),
    ],
  );
}
