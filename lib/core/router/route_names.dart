/// Defines route names and paths constants to avoid hardcoding strings.
abstract class AppRoutes {
  // Auth Routes
  static const String loginName = 'login';
  static const String loginPath = '/login';

  static const String registerName = 'register';
  static const String registerPath = '/register';

  // Groups Tab Routes (Nested inside StatefulShellRoute)
  static const String groupsName = 'groups';
  static const String groupsPath = '/groups';

  static const String groupDetailsName = 'groupDetails';
  static const String groupDetailsPath = 'details/:groupId'; // Nested sub-route

  static const String addExpenseName = 'addExpense';
  static const String addExpensePath = 'details/:groupId/expenses/new';

  static const String groupMembersName = 'groupMembers';
  static const String groupMembersPath = 'details/:groupId/members';

  // Profile Tab Routes (Nested inside StatefulShellRoute)
  static const String profileName = 'profile';
  static const String profilePath = '/profile';
}
