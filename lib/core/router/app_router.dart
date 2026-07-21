import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splito_flutter/core/router/route_names.dart';
import 'package:splito_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:splito_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:splito_flutter/features/auth/presentation/pages/email_verification_pending_page.dart';
import 'package:splito_flutter/features/auth/presentation/pages/verify_email_landing_page.dart';
import 'package:splito_flutter/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:splito_flutter/features/auth/presentation/pages/reset_password_landing_page.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_details_page.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_list_page.dart';
import 'package:splito_flutter/features/groups/presentation/pages/group_members_page.dart';
import 'package:splito_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:splito_flutter/features/groups/domain/entities/group_member.dart';
import 'package:splito_flutter/features/expenses/presentation/pages/create_expense_page.dart';
import 'package:splito_flutter/features/expenses/presentation/pages/expense_detail_page.dart';
import 'package:splito_flutter/features/expenses/presentation/pages/expense_list_page.dart';
import 'package:splito_flutter/features/balances/presentation/pages/group_balances_page.dart';
import 'package:splito_flutter/features/settlements/presentation/pages/settlement_list_page.dart';
import 'package:splito_flutter/features/settlements/presentation/pages/create_settlement_page.dart';
import 'package:splito_flutter/features/activity/presentation/pages/activity_feed_page.dart';
import 'package:splito_flutter/features/notifications/presentation/pages/notifications_page.dart';
import 'package:splito_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:splito_flutter/features/analytics/presentation/pages/group_analytics_page.dart';
import 'package:splito_flutter/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:splito_flutter/features/expenses/presentation/pages/global_expenses_page.dart';
import 'package:splito_flutter/features/activity/presentation/pages/global_activity_page.dart';
import 'package:splito_flutter/features/analytics/presentation/pages/global_statistics_page.dart';
import 'package:splito_flutter/features/navigation/presentation/widgets/responsive_navigation_shell.dart';

/// Global navigator keys for context access.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final dashboardTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardTab');
final groupsTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'groupsTab');
final expensesTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'expensesTab');
final activityTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'activityTab');
final statisticsTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'statisticsTab');
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
    initialLocation: AppRoutes.dashboardPath,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.valueOrNull is AuthStateAuthenticated;

      // If authNotifierProvider is loading → return null (stay on current)
      if (authState.isLoading) return null;

      final isAuthRoute = state.matchedLocation == AppRoutes.loginPath ||
          state.matchedLocation == AppRoutes.registerPath ||
          state.matchedLocation == AppRoutes.verifyEmailPendingPath ||
          state.matchedLocation == AppRoutes.verifyEmailPath ||
          state.matchedLocation == AppRoutes.forgotPasswordPath ||
          state.matchedLocation == AppRoutes.resetPasswordPath;

      // Unauthenticated users are redirected to login page
      if (!isAuthenticated) {
        if (isAuthRoute) return null;
        return AppRoutes.loginPath;
      }

      // Authenticated users are redirected away from auth pages to main dashboard
      if (isAuthRoute) {
        return AppRoutes.dashboardPath;
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
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.verifyEmailPendingName,
        path: AppRoutes.verifyEmailPendingPath,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationPendingPage(email: email);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.verifyEmailName,
        path: AppRoutes.verifyEmailPath,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return VerifyEmailLandingPage(token: token);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.forgotPasswordName,
        path: AppRoutes.forgotPasswordPath,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.resetPasswordName,
        path: AppRoutes.resetPasswordPath,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordLandingPage(token: token);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.notificationsName,
        path: AppRoutes.notificationsPath,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.settingsName,
        path: AppRoutes.settingsPath,
        builder: (context, state) => const SettingsPage(),
      ),

      // Main Dashboard Shell (Stateful Nested Navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard Branch (0)
          StatefulShellBranch(
            navigatorKey: dashboardTabNavigatorKey,
            routes: [
              GoRoute(
                name: AppRoutes.dashboardName,
                path: AppRoutes.dashboardPath,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Groups Branch (1)
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
                      GoRoute(
                        name: AppRoutes.groupBalancesName,
                        path: AppRoutes.groupBalancesPath,
                        builder: (context, state) {
                          final groupId = state.pathParameters['groupId'] ?? '';
                          final extra = state.extra as Map<String, dynamic>?;
                          final groupName = extra?['groupName'] as String? ?? '';
                          final currency = extra?['currency'] as String? ?? 'INR';
                          return GroupBalancesPage(
                            groupId: groupId,
                            groupName: groupName,
                            currency: currency,
                          );
                        },
                      ),
                      GoRoute(
                        name: AppRoutes.settlementListName,
                        path: AppRoutes.settlementListPath,
                        builder: (context, state) {
                          final groupId = state.pathParameters['groupId'] ?? '';
                          final extra = state.extra as Map<String, dynamic>?;
                          final groupName = extra?['groupName'] as String? ?? '';
                          return SettlementListPage(
                            groupId: groupId,
                            groupName: groupName,
                          );
                        },
                      ),
                      GoRoute(
                        name: AppRoutes.createSettlementName,
                        path: AppRoutes.createSettlementPath,
                        builder: (context, state) {
                          final groupId = state.pathParameters['groupId'] ?? '';
                          final extra = state.extra as Map<String, dynamic>?;
                          final groupName = extra?['groupName'] as String? ?? '';
                          final currency = extra?['currency'] as String? ?? 'INR';
                          final members = extra?['members'] as List<GroupMember>? ?? [];
                          final prefilledFromUserId = extra?['prefilledFromUserId'] as String?;
                          final prefilledToUserId = extra?['prefilledToUserId'] as String?;
                          return CreateSettlementPage(
                            groupId: groupId,
                            groupName: groupName,
                            currency: currency,
                            members: members,
                            prefilledFromUserId: prefilledFromUserId,
                            prefilledToUserId: prefilledToUserId,
                          );
                        },
                      ),
                      GoRoute(
                        name: AppRoutes.activityFeedName,
                        path: AppRoutes.activityFeedPath,
                        builder: (context, state) {
                          final groupId = state.pathParameters['groupId'] ?? '';
                          final extra = state.extra as Map<String, dynamic>?;
                          final groupName = extra?['groupName'] as String? ?? '';
                          return ActivityFeedPage(
                            groupId: groupId,
                            groupName: groupName,
                          );
                        },
                      ),
                      GoRoute(
                        name: AppRoutes.groupAnalyticsName,
                        path: AppRoutes.groupAnalyticsPath,
                        builder: (context, state) {
                          final groupId = state.pathParameters['groupId'] ?? '';
                          final extra = state.extra as Map<String, dynamic>?;
                          final groupName = extra?['groupName'] as String? ?? '';
                          final currency = extra?['currency'] as String? ?? 'INR';
                          return GroupAnalyticsPage(
                            groupId: groupId,
                            groupName: groupName,
                            currency: currency,
                          );
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

          // Expenses Branch (2)
          StatefulShellBranch(
            navigatorKey: expensesTabNavigatorKey,
            routes: [
              GoRoute(
                name: AppRoutes.globalExpensesName,
                path: AppRoutes.globalExpensesPath,
                builder: (context, state) => const GlobalExpensesPage(),
              ),
            ],
          ),

          // Activity Branch (3)
          StatefulShellBranch(
            navigatorKey: activityTabNavigatorKey,
            routes: [
              GoRoute(
                name: AppRoutes.globalActivityName,
                path: AppRoutes.globalActivityPath,
                builder: (context, state) => const GlobalActivityPage(),
              ),
            ],
          ),

          // Statistics Branch (4)
          StatefulShellBranch(
            navigatorKey: statisticsTabNavigatorKey,
            routes: [
              GoRoute(
                name: AppRoutes.globalStatisticsName,
                path: AppRoutes.globalStatisticsPath,
                builder: (context, state) => const GlobalStatisticsPage(),
              ),
            ],
          ),

          // Profile Branch (5)
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
