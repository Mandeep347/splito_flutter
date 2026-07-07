# Splito — Project Context & Transfer Documentation

This document serves as a complete project context, architecture summary, and development log for **Splito** (a production-grade Splitwise-like expense splitting app). Use this document to transfer the complete state of the project to another chatbot or developer.

---

## 1. Technical Stack & Architecture

### Backend & Database
- **Backend Framework**: FastAPI (Python)
- **Database**: PostgreSQL
- **Note**: No backend modifications are allowed; all features computed in Phase 8 are performed purely client-side from local cached or fetched state.

### Frontend (Flutter/Dart)
- **State Management**: `flutter_riverpod` (plain `Provider`/`AsyncNotifierProvider` - **no code generation or `@riverpod` annotations**).
- **Navigation**: `go_router` (v14+) with nested routing structures.
- **Networking**: `dio` with configured clients.
- **Serialization / Code Gen**: `freezed` and `json_serializable` (used for data/domain models).
- **Storage**: `hive_flutter` (local caching) and `flutter_secure_storage` (secure auth tokens).
- **External UI Libraries**: `fl_chart: ^0.69.0` (for monthly and member contribution visualizations).
- **Utility / Share**: `share_plus: ^10.0.0` (for text summary sharing).

### Folder Structure (Feature-First + Clean Architecture)
The codebase uses a **Feature-first + Clean Architecture** structure:
```
lib/
├── core/                       # Shared/core infrastructure
│   ├── constants/              # App constants, storage keys
│   ├── errors/                 # Exception and Failure definitions
│   ├── network/                # Dio client configuration
│   ├── router/                 # GoRouter app router and route names
│   ├── theme/                  # Theme configuration, financial colors
│   └── storage/                # Hive storage services
└── features/                   # Features (feature-first)
    ├── auth/                   # Authentication logic
    ├── groups/                 # Group management (list, details, cards)
    ├── expenses/               # Expense management, search, and filtering
    ├── settlements/            # Debt settlements
    └── analytics/              # Client-side analytics (Phase 8)
        ├── domain/
        │   ├── entities/       # GroupAnalytics, MemberContribution, MonthlySpending
        │   └── services/       # AnalyticsComputationService, ExportService
        └── presentation/
            ├── pages/          # GroupAnalyticsPage
            ├── providers/      # Analytics providers (State management)
            └── widgets/        # Charts, summary widgets
```

---

## 2. Rules & Design Constraints
1. **Async State Management**:
   - Every asynchronous provider must extend `FamilyAsyncNotifier` or `AsyncNotifier`.
   - Never use direct argument names like `'arg'`. Use semantically named fields or private references.
   - **Auth Guard**: Check `authStateProvider` inside the `build()` method. If the user is unauthenticated, return a safe default state immediately without triggering API or storage requests.
   - Catch only custom sub-types of `Failure` (e.g., `NetworkFailure`, `BusinessRuleFailure`), and rethrow or handle them gracefully without re-wrapping.
2. **Visual Aesthetics**:
   - Modern, high-premium theme using `Theme.of(context)` with HSL-derived color palettes and dark mode support.
   - Utilize existing widgets like `AmountDisplay` for currency formatting.
   - Use `SizedBox.shrink()` during loading/error of optional widgets to avoid blocking the main UI thread.
3. **No Placeholders**: All layouts must be fully fleshed out with active logic, utilizing unit/widget test coverage.

---

## 3. History of Completed Phases

### Phases 1–7: Core Features (Complete)
Established:
- Authentication & Session storage (`flutter_secure_storage`).
- Group creation, memberships, detail editing, and archiving.
- Expense creation, splitting strategies (Equal, Exact, Percentage, Shares), and editing.
- Local database caching using Hive box adapters.
- Balance computation, debt calculations, and Settlement generation.

---

### Phase 8: Analytics, Search, and Share (In Progress)

#### Phase 8.1: Domain Layer & Core Computations
- Created domain entities in `lib/features/analytics/domain/entities/`:
  - [group_analytics.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/domain/entities/group_analytics.dart): Defines metadata like total expenses, settlement rates, monthly breakdowns, and payer distributions.
  - [member_contribution.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/domain/entities/member_contribution.dart): Holds calculation fields for who paid, who owed, and net outstanding shares.
  - [monthly_spending.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/domain/entities/monthly_spending.dart): Holds month-over-month total spending figures.
- Built [analytics_computation_service.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/domain/services/analytics_computation_service.dart) to compute all group analytics client-side from cached groups, expenses, and settlements.

#### Phase 8.2: State Management (Riverpod Providers)
- Created [analytics_providers.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/presentation/providers/analytics_providers.dart):
  - Wires `ComputeGroupAnalyticsUseCase` to `groupAnalyticsProvider`.
  - Defines `groupTotalSpentProvider` and `groupTopPayerProvider` as derived providers.
  - Created `expenseSearchProvider` and its notifier to handle local multi-criteria filters (by query string, date range, payer, or split type).

#### Phase 8.3: Analytics Chart Widgets
- Built chart widgets using `fl_chart`:
  - [monthly_spending_chart.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/presentation/widgets/monthly_spending_chart.dart): Renders a monthly spending vertical bar chart.
  - [member_contribution_chart.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/presentation/widgets/member_contribution_chart.dart): Renders contribution breakdowns in a horizontal bar format.

#### Phase 8.4: Group Analytics Page
- Created [group_analytics_page.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/presentation/pages/group_analytics_page.dart).
- Nested its route (`groupAnalyticsPath`) inside the group details path structure in [app_router.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/core/router/app_router.dart).

#### Phase 8.5: Expense Search UI
- Created [expense_filter_sheet.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/expenses/presentation/widgets/expense_filter_sheet.dart) modal bottom sheet for filtering options.
- Integrated the search bar and filter sheet directly into the group details screen.

#### Phase 8.6: Export Summary & Native Share
- Built [export_service.dart](file:///d:/Coding/Projects/Splito/splito_flutter/lib/features/analytics/domain/services/export_service.dart) to generate a text-based summary of group totals, average spend, top payer, monthly totals (limited to 6 months), and member breakdowns.
- Updated `GroupAnalyticsPage` with an AppBar action icon using `share_plus` to invoke native platform sharing options.
- Wrote full unit test coverage in [export_service_test.dart](file:///d:/Coding/Projects/Splito/splito_flutter/test/features/analytics/domain/services/export_service_test.dart) verifying fallback and limit rules.

---

## 4. Current Work: Phase 8.7 (Pending Implementation)

The task is to surface analytics summaries on the Group List and Details pages:

1. **`lib/features/groups/presentation/widgets/group_card.dart`**:
   - Watch `groupTotalSpentProvider(group.id)`.
   - If total spent > 0, show a row under the balance summary containing `Icons.receipt_long_outlined` (size 12) and a text indicator of the total spent (e.g. `$250 total`).
   - Add private helper `_currencySymbol(String c)` supporting currency conversions.
   - Add comment explaining N+1 computation characteristics:
     `// PERF NOTE: each GroupCard triggers a separate analytics computation via groupAnalyticsProvider. Phase 10 will optimise this with a batch endpoint or client-side cache.`

2. **`lib/features/groups/presentation/pages/group_details_page.dart`**:
   - Watch `groupAnalyticsProvider(group.id)`.
   - Show a compact teaser card (using `SizedBox.shrink()` on loading/error/no-data) under group metadata:
     - Left: "Total spent" label + `AmountDisplay` value.
     - Center: "Avg expense" label + `AmountDisplay` value.
     - Right: TextButton labeled `"Analytics →"` navigating to the full analytics screen via `context.goNamed`.

3. **`lib/features/groups/presentation/pages/group_list_page.dart`**:
   - Document pull-to-refresh dependency with a comment:
     `// Analytics is derived from expenses — invalidating groupExpensesProvider causes analytics to recompute automatically. No explicit analytics invalidation needed.`

---

## 5. Development Tools & Commands
To verify the application status:
- Fetch packages:
  ```powershell
  flutter pub get
  ```
- Run tests:
  ```powershell
  flutter test
  ```
- Run dev server / run local app:
  ```powershell
  flutter run
  ```
- Generate code structures (when modifying Freezed/JsonSerializable):
  ```powershell
  dart run build_runner build --delete-conflicting-outputs
  ```
