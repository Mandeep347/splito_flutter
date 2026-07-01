import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splito_flutter/core/router/route_names.dart';
import 'package:splito_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:splito_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_details_page.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_list_page.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_members_page.dart';
import 'package:splito_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:splito_flutter/features/groups/domain/entities/group_member.dart';
import 'package:splito_flutter/features/expenses/presentation/pages/create_expense_page.dart';
import 'package:splito_flutter/features/expenses/presentation/pages/expense_detail_page.dart';
import 'package:splito_flutter/features/expenses/presentation/pages/expense_list_page.dart';

/// Global navigator keys for context access.
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
  
  // Changed: Removed ref.watch(authNotifierProvider) from provider body to prevent router rebuilds. Auth state is instead retrieved via ref.read inside the redirect callback.
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.groupsPath,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.valueOrNull is AuthStateAuthenticated;

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
                    routes: [
                      GoRoute(
                        name: AppRoutes.createExpenseName,
                        path: AppRoutes.createExpensePath,
                        builder: (context, state) {
                          final groupId = state.pathParameters['groupId'] ?? '';
                          final extra = state.extra as Map<String, dynamic>?;
                          final groupName = extra?['groupName'] as String? ?? '';
                          final currency = extra?['currency'] as String? ?? 'INR';
                          final members = extra?['members'] as List<GroupMember>? ?? [];
                          return CreateExpensePage(
                            groupId: groupId,
                            groupName: groupName,
                            currency: currency,
                            members: members,
                          );
                        },
                      ),
                      GoRoute(
                        name: AppRoutes.expenseDetailName,
                        path: AppRoutes.expenseDetailPath,
                        builder: (context, state) {
                          final expenseId = state.pathParameters['expenseId'] ?? '';
                          return ExpenseDetailPage(expenseId: expenseId);
                        },
                      ),
                      GoRoute(
                        name: AppRoutes.expenseListName,
                        path: AppRoutes.expenseListPath,
                        builder: (context, state) {
                          final groupId = state.pathParameters['groupId'] ?? '';
                          final extra = state.extra as Map<String, dynamic>?;
                          final groupName = extra?['groupName'] as String? ?? '';
                          return ExpenseListPage(groupId: groupId, groupName: groupName);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: AppRoutes.groupMembersName,
                    path: AppRoutes.groupMembersPath,
                    builder: (context, state) {
                      final groupId = state.pathParameters['groupId'] ?? '';
                      final extra = state.extra as Map<String, dynamic>?;
                      final groupCreatedBy = extra?['createdBy'] as String? ?? '';
                      return GroupMembersPage(
                        groupId: groupId,
                        groupCreatedBy: groupCreatedBy,
                      );
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
