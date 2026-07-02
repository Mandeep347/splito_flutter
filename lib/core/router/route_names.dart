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

  static const String createExpenseName = 'createExpense';
  static const String createExpensePath = 'expenses/new';

  static const String expenseListName = 'expenseList';
  static const String expenseListPath = 'expenses';

  static const String expenseDetailName = 'expenseDetail';
  static const String expenseDetailPath = 'expenses/:expenseId';
 
  static const String groupBalancesPath = 'balances';
  static const String groupBalancesName = 'groupBalances';
  static const String settlementListPath = 'settlements';
  static const String settlementListName = 'settlementList';
  static const String createSettlementPath = 'settlements/new';
  static const String createSettlementName = 'createSettlement';

  static const String groupMembersName = 'groupMembers';
  static const String groupMembersPath = 'details/:groupId/members';

  // Profile Tab Routes (Nested inside StatefulShellRoute)
  static const String profileName = 'profile';
  static const String profilePath = '/profile';
}
