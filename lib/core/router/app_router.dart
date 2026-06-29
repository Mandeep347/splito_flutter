import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splito_flutter/core/router/route_names.dart';
import 'package:splito_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:splito_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_details_page.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_list_page.dart';
import 'package:splito_flutter/features/profile/presentation/pages/profile_page.dart';

/// Global navigator keys for routing context access.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final groupsTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'groupsTab');
final profileTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileTab');

/// Notifier that triggers GoRouter refreshes on Riverpod provider updates.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(
      authNotifierProvider,
      (previous, next) {
        if (previous?.valueOrNull != next.valueOrNull) {
          notifyListeners();
        }
      },
    );
  }
}

/// RouterNotifier provider initialization.
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Riverpod provider for GoRouter instance.
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  
  // Watch the authenticating state directly within the provider closure.
  // When auth state changes, the provider rebuilds and triggers redirect logic re-evaluation.
  final authState = ref.watch(authNotifierProvider);
  final isAuthenticated = authState.valueOrNull is AuthStateAuthenticated;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.groupsPath,
    refreshListenable: notifier,
    redirect: (context, state) {
      // If authNotifierProvider is loading → return null (stay on current)
      if (authState.isLoading) return null;

      final isLoggingIn = state.matchedLocation == AppRoutes.loginPath;
      final isRegistering = state.matchedLocation == AppRoutes.registerPath;

      // Unauthenticated users are redirected to login page
      if (!isAuthenticated) {
        if (isLoggingIn || isRegistering) return null;
        return AppRoutes.loginPath;
      }

      // Authenticated users are redirected away from auth pages to main dashboard
      if (isLoggingIn || isRegistering) {
        return AppRoutes.groupsPath;
      }

      return null;
    },
    routes: [
      // Auth Screen Routes
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.loginName,
        path: AppRoutes.loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.registerName,
        path: AppRoutes.registerPath,
        builder: (context, state) => const RegisterPage(),
      ),

      // Main Dashboard Shell (Stateful Nested Navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Groups Branch
          StatefulShellBranch(
            navigatorKey: groupsTabNavigatorKey,
            routes: [
              GoRoute(
                name: AppRoutes.groupsName,
                path: AppRoutes.groupsPath,
                builder: (context, state) => const GroupListPage(),
                routes: [
                  GoRoute(
                    name: AppRoutes.groupDetailsName,
                    path: AppRoutes.groupDetailsPath,
                    builder: (context, state) {
                      final groupId = state.pathParameters['groupId'] ?? '';
                      return GroupDetailsPage(groupId: groupId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Profile Branch
          StatefulShellBranch(
            navigatorKey: profileTabNavigatorKey,
            routes: [
              GoRoute(
                name: AppRoutes.profileName,
                path: AppRoutes.profilePath,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Shared structural layout wrapper for bottom navigation tabs in Splito.
class ScaffoldWithNestedNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
