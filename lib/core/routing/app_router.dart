import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/core/routing/route_paths.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/auth/presentation/screens/login_screen.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_list_screen.dart';
import 'package:saree_sutra/features/challans/presentation/screens/create_challan_screen.dart';
import 'package:saree_sutra/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:saree_sutra/features/dashboard/presentation/screens/stitching_user_dashboard_screen.dart';
import 'package:saree_sutra/features/dashboard/presentation/screens/supplier_dashboard_screen.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/screens/deposit_requests_screen.dart';
import 'package:saree_sutra/features/products/presentation/screens/products_screen.dart';
import 'package:saree_sutra/features/stitching_ledger/presentation/screens/pending_returns_ledger_screen.dart';
import 'package:saree_sutra/features/stitching_ledger/presentation/screens/stitching_ledger_screen.dart';
import 'package:saree_sutra/features/supplier_ledger/presentation/screens/supplier_ledger_screen.dart';
import 'package:saree_sutra/features/suppliers/presentation/screens/supplier_pending_materials_screen.dart';
import 'package:saree_sutra/features/suppliers/presentation/screens/suppliers_screen.dart';
import 'package:saree_sutra/features/users/presentation/screens/stitching_users_screen.dart';


class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
  }
}

String _homeRouteForRole(UserRole role) {
  return switch (role) {
    UserRole.admin => RoutePaths.adminDashboard,
    UserRole.stitchingUser => RoutePaths.stitchingDashboard,
    UserRole.supplier => RoutePaths.supplierDashboard,
  };
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: RoutePaths.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateChangesProvider);
      final user = authAsync.asData?.value;
      final isLoggingIn = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.forgotPassword;

      if (user == null) {
        return isLoggingIn ? null : RoutePaths.login;
      }

      final homeRoute = _homeRouteForRole(user.role);

      if (isLoggingIn) return homeRoute;

      final isOnOwnShell = switch (user.role) {
        UserRole.admin =>
          state.matchedLocation.startsWith(RoutePaths.adminDashboard),
        UserRole.stitchingUser =>
          state.matchedLocation.startsWith(RoutePaths.stitchingDashboard),
        UserRole.supplier =>
          state.matchedLocation.startsWith(RoutePaths.supplierDashboard),
      };
      if (!isOnOwnShell) return homeRoute;

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'suppliers',
            builder: (context, state) => const SuppliersScreen(),
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const StitchingUsersScreen(),
          ),
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: 'challans',
            builder: (context, state) => const ChallanListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateChallanScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'deposit-requests',
            builder: (context, state) => const DepositRequestsScreen(),
          ),
          GoRoute(
            path: 'supplier-ledger',
            builder: (context, state) => const SupplierLedgerScreen(),
          ),
          GoRoute(
            path: 'stitching-ledger',
            builder: (context, state) => const StitchingLedgerScreen(),
          ),
          GoRoute(
            path: 'pending-returns-ledger',
            builder: (context, state) => const PendingReturnsLedgerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.stitchingDashboard,
        builder: (context, state) => const StitchingUserDashboardScreen(),
        routes: [
          GoRoute(
            path: 'ledger',
            builder: (context, state) => const StitchingLedgerScreen(),
          ),
          GoRoute(
            path: 'pending-returns-ledger',
            builder: (context, state) => const PendingReturnsLedgerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.supplierDashboard,
        builder: (context, state) => const SupplierDashboardScreen(),
        routes: [
          GoRoute(
            path: 'challans',
            builder: (context, state) => const ChallanListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateChallanScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'ledger',
            builder: (context, state) => const SupplierLedgerScreen(),
          ),
          GoRoute(
            path: 'pending-materials',
            builder: (context, state) {
              final authUser = ProviderScope.containerOf(context, listen: false)
                  .read(authStateChangesProvider)
                  .value;
              final extra = state.extra;
              final MaterialType? initialType = extra is MaterialType
                  ? extra
                  : (state.uri.queryParameters['type'] != null
                      ? MaterialType.fromValue(
                          state.uri.queryParameters['type'],
                        )
                      : null);
              return SupplierPendingMaterialsScreen(
                supplierId: authUser?.supplierId ?? '',
                initialMaterialType: initialType,
              );
            },
          ),
        ],
      ),
    ],
  );
});
