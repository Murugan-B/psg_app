import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vishnu_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:vishnu_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:vishnu_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:vishnu_mobile/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:vishnu_mobile/core/router/scaffold_with_nav_bar.dart';

import 'package:vishnu_mobile/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:vishnu_mobile/features/admin/presentation/screens/admin_stock_screen.dart';
import 'package:vishnu_mobile/features/admin/presentation/screens/admin_pos_screen.dart';
import 'package:vishnu_mobile/features/admin/presentation/screens/admin_staff_screen.dart';
import 'package:vishnu_mobile/features/admin/presentation/screens/admin_report_screen.dart';
import 'package:vishnu_mobile/features/admin/presentation/screens/admin_products_screen.dart';

import 'package:vishnu_mobile/features/staff/presentation/screens/staff_home_screen.dart';
import 'package:vishnu_mobile/features/staff/presentation/screens/staff_pos_screen.dart';
import 'package:vishnu_mobile/features/staff/presentation/screens/staff_attendance_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      // Wait for initialization or loading
      if (authState is AsyncLoading) return null;
      
      final profile = authState.value;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';
      
      if (isSplash) return null;

      if (profile == null) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        if (!profile.isApproved && !profile.isAdmin) return '/pending-approval';
        if (profile.isAdmin) return '/admin/home';
        return '/staff/home';
      }

      if (!profile.isApproved && !profile.isAdmin) {
        return state.matchedLocation == '/pending-approval' ? null : '/pending-approval';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(
          onFinish: () {
            context.go('/login');
          },
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/home',
                builder: (context, state) => const AdminHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/stock',
                builder: (context, state) => const AdminStockScreen(),
                routes: [
                  GoRoute(
                    path: 'products',
                    builder: (context, state) => const AdminProductsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/pos',
                builder: (context, state) => const AdminPosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/staff',
                builder: (context, state) => const AdminStaffScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/report',
                builder: (context, state) => const AdminReportScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/home',
                builder: (context, state) => const StaffHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/pos',
                builder: (context, state) => const StaffPosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/attendance',
                builder: (context, state) => const StaffAttendanceScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
