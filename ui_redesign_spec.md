# Splito UI Redesign Specification Reference

This document maps out the design tokens, routing architectures, reusable UI components, and state/provider bindings for all major screens of the **Splito** app. Use this reference in the next chat to completely redesign the application interface while preserving core logic, state-management paths, and usecase integrations.

---

## 1. Design System & Theme Tokens

The design system is managed via [custom_theme.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/core/theme/custom_theme.dart) and uses modern Slate-based light/dark modes with an Indigo/Teal/Rose financial theme.

### Color Schemes ([color_schemes.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/core/theme/color_schemes.dart))
- **Primary**: Indigo-600 Light (`#4F46E5`) / Indigo-500 Dark (`#6366F1`)
- **Secondary**: Teal-600 Light (`#0D9488`) / Teal-500 Dark (`#14B8A6`)
- **Tertiary**: Rose-600 Light (`#E11D48`) / Rose-400 Dark (`#FB7185`)
- **Background**: Slate-50 Light (`#F8FAFC`) / Dark deep slate (`#090D16`)
- **Surface**: Pure White Light (`#FFFFFF`) / Dark slate (`#131B2E`)
- **Borders & Dividers**: Slate-200 Light (`#E2E8F0`) / Slate-800 Dark (`#1E293B`)
- **Subtitles & Secondary Text**: Slate-600 Light (`#475569`) / Slate-400 Dark (`#94A3B8`)

### Semantic Financial Colors ([financial_colors.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/core/theme/financial_colors.dart))
- **`oweColor`**: Red indicating the current user owes money (`Colors.red.shade600`).
- **`owedColor`**: Green indicating someone owes the current user money (`Colors.green.shade600`).

### Layout & Theme Extensions ([theme_extensions.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/core/theme/theme_extensions.dart))
Access these tokens in widgets via `Theme.of(context).extension<AppThemeExtension>()!`:
- **Spacing**:
  - `spaceXXS`: 2.0 | `spaceXS`: 4.0 | `spaceSM`: 8.0 | `spaceMD`: 12.0
  - `spaceLG`: 16.0 | `spaceXL`: 24.0 | `spaceXXL`: 32.0 | `spaceXXXL`: 48.0
- **Radii**:
  - `radiusXS`: 4.0 | `radiusSM`: 8.0 | `radiusMD`: 12.0
  - `radiusLG`: 16.0 | `radiusXL`: 24.0 | `radiusRound`: 999.0
- **Gradient**: `primaryGradient` (Indigo gradient linear flow)
- **Glassmorphism Overlay**: `glassOverlay` (Translucent overlay for blurred cards)
- **Card Shadow**: `cardShadow` (Subtle slate shadow in light theme, heavy dark shadow in dark theme)

---

## 2. Routing Architecture

Routing is managed via `GoRouter` in [app_router.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/core/router/app_router.dart). All route names and paths are declared in [route_names.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/core/router/route_names.dart).

```
Root Navigator
├── /login (LoginPage)
├── /register (RegisterPage)
├── /notifications (NotificationsPage)
├── /settings (SettingsPage)
└── Shell Route (ScaffoldWithNestedNavigation - bottom tabs)
    ├── Tab 1: /groups (GroupListPage)
    │   └── /groups/:groupId (GroupDetailsPage)
    │       ├── /members (GroupMembersPage)
    │       ├── /expenses/new (CreateExpensePage)
    │       ├── /expenses/:expenseId (ExpenseDetailPage)
    │       ├── /expenses (ExpenseListPage)
    │       ├── /balances (GroupBalancesPage)
    │       ├── /settlements/new (CreateSettlementPage)
    │       ├── /settlements (SettlementListPage)
    │       ├── /activity (ActivityFeedPage)
    │       └── /analytics (GroupAnalyticsPage)
    └── Tab 2: /profile (ProfilePage)
```

---

## 3. Reusable UI Components

These shared components are located in `lib/shared/widgets/` and are reused across screens.

| Component | Path | Description & Details |
| :--- | :--- | :--- |
| **`overall_balance_card.dart`** | `lib/shared/widgets/overall_balance_card.dart` | Net total balance card (Green if owed, Red if owes). Displays net amounts across all groups. |
| **`balance_row.dart`** | `lib/shared/widgets/balance_row.dart` | Row illustrating balance status between two members with name, avatar, and amount indicator. |
| **`amount_display.dart`** | `lib/shared/widgets/amount_display.dart` | Unified format displaying currency and formatted numbers safely (money fields). |
| **`member_avatar.dart`** | `lib/shared/widgets/member_avatar.dart` | Displays member initials (derived from `initials` property) or image. Uses slate placeholder colors. |
| **`app_text_field.dart`** | `lib/shared/widgets/app_text_field.dart` | Custom modern input fields with support for labels, errors, prefixes, and rounded styling. |
| **`primary_button.dart`** | `lib/shared/widgets/primary_button.dart` | Large gradient button used for main call-to-actions, with optional loading states. |
| **`settlement_list_tile.dart`**| `lib/shared/widgets/settlement_list_tile.dart` | Standard tile for recorded settlements (A paid B) with formatted details. |
| **`empty_state_widget.dart`** | `lib/shared/widgets/empty_state_widget.dart` | Standardized illustration + text placeholder displayed when collections are empty. |
| **`notification_bell.dart`** | `lib/shared/widgets/notification_bell.dart` | App bar notification bell with a red badge showing unread notification counts. |
| **`group_card.dart`** | `lib/features/groups/presentation/widgets/group_card.dart` | Group summaries in Group List: displays group title, members count, total spent, and user balance. |
| **`analytics_summary_card.dart`**| `lib/features/analytics/presentation/widgets/` | Displays top-level values for Total Spent, My Share, and Net Balances in analytics. |
| **`monthly_spending_chart.dart`**| `lib/features/analytics/presentation/widgets/` | Renders monthly spending trends (bar/line chart). |
| **`member_contribution_chart.dart`**| `lib/features/analytics/presentation/widgets/` | Renders a donut/pie chart representing the division of expenses among members. |
| **`top_payer_badge.dart`** | `lib/features/analytics/presentation/widgets/` | Profile badge representing the user who paid the highest amount in the group. |

---

## 4. Major Screens & State Binding Reference

This reference is critical for maintaining correct data bindings while redesigning screens:

### A. Group List Screen (`GroupListPage`)
* **Path**: `/groups`
* **Riverpod Providers Watched**:
  * `groupsProvider` (list of all groups the user belongs to).
  * `myOverallBalancesProvider` (user net total balance across all groups).
  * `hasUnreadProvider` (unread notifications check for the bell icon).
* **Interactions**:
  * Tap "Settle Up" -> opens a bottom sheet/modal.
  * Tap "+" floating action button -> opens `CreateGroupSheet` modal.

### B. Group Details Screen (`GroupDetailsPage`)
* **Path**: `/groups/:groupId`
* **Riverpod Providers Watched**:
  * `groupDetailsProvider(groupId)` (fetches Group entity details).
  * `groupBalancesProvider(groupId)` (calculates net balances for the group members).
  * `groupTotalSpentProvider(groupId)` (sum of all group expenses).
  * `groupActivityProvider(groupId)` (paginated recent activities feed preview).
* **Interactions**:
  * Header displays group name, default currency, and Quick Action buttons: **Settle Up**, **Add Expense**, **Balances**, and **Activity**.
  * Edit Group Name -> opens `EditGroupNameSheet` modal.
  * Tap members count -> navigates to Group Members Screen.
  * "Recent Activity" card preview redirects to Activity Feed Page.

### C. Group Members Screen (`GroupMembersPage`)
* **Path**: `/groups/:groupId/members`
* **Riverpod Providers Watched**:
  * `groupMembersProvider(groupId)` (list of members in the group).
* **Interactions**:
  * Group creator has authority to remove members (via `delete` call on `groupMembersProvider(groupId).notifier`).
  * Tap "Add Member" -> opens `AddMemberSheet` modal.

### D. Create/Edit Expense Screen (`CreateExpensePage`)
* **Path**: `/groups/:groupId/expenses/new`
* **State Managed**: local controllers for `title`, `amount`, `splitType` (Equal, Exact, Percentage, Share), and selected participants.
* **Interactions**:
  * Automatically handles splits validation (e.g. percentages must sum to 100%, exact shares must sum to total).
  * On success, invalidates `groupBalancesProvider(groupId)`, `groupExpensesProvider(groupId)`, and `groupTotalSpentProvider(groupId)`.

### E. Expense Details Screen (`ExpenseDetailPage`)
* **Path**: `/groups/:groupId/expenses/:expenseId`
* **Riverpod Providers Watched**:
  * `expenseDetailProvider(expenseId)` (details of a single expense).
* **Interactions**:
  * Edit Title/Description -> triggers edit sheet.
  * Reverse Expense -> soft-delete button (restores user balances).

### F. Group Balances & Settlement Screens (`GroupBalancesPage`, `CreateSettlementPage`)
* **Path**: `/groups/:groupId/balances` / `/groups/:groupId/settlements/new`
* **Riverpod Providers Watched**:
  * `simplifiedBalancesProvider(groupId)` (fetches debt-simplified transactions list).
  * `settlementListProvider(groupId)` (recorded payments list).
* **Interactions**:
  * Group Balances screen shows a list of "who owes who how much" with a quick settle option next to each row.
  * Settle button redirects to `CreateSettlementPage` pre-populating `fromUserId` and `toUserId`.

### G. Activity Feed Screen (`ActivityFeedPage`)
* **Path**: `/groups/:groupId/activity`
* **Riverpod Providers Watched**:
  * `groupActivityProvider(groupId)` (aggregates members, expenses, and settlements into activity list).
* **Interactions**:
  * Pull-to-refresh invalidates the feed notifier.
  * Infinite scroll triggers `loadNextPage()` on notifier.

### H. Group Analytics Screen (`GroupAnalyticsPage`)
* **Path**: `/groups/:groupId/analytics`
* **Riverpod Providers Watched**:
  * `groupAnalyticsProvider(groupId)` (pre-calculated analytics parameters like total spending, user share, monthly trends, and peer contribution slices).
* **Interactions**:
  * Renders `monthly_spending_chart.dart` and `member_contribution_chart.dart`.
  * Renders badges like "Top Payer".

### I. Profile & Settings Screens (`ProfilePage`, `SettingsPage`)
* **Path**: `/profile` / `/settings`
* **Riverpod Providers Watched**:
  * `myProfileProvider` (user profile parameters).
  * `settingsNotifierProvider` (app-wide settings like theme mode (System/Light/Dark) and default currency).
* **Interactions**:
  * Edit profile triggers a bottom sheet modification modal.
  * Logout clears the credentials cache and redirects the GoRouter to `/login`.
