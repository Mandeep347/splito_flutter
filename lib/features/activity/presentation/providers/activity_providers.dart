import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:splito_flutter/features/activity/domain/entities/activity_feed.dart';
import 'package:splito_flutter/features/activity/domain/usecases/get_group_activities_usecase.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';

// ============================================================================
// UseCase Providers
// ============================================================================

/// Provider exposing [GetGroupActivitiesUseCase].
final getGroupActivitiesUseCaseProvider = Provider<GetGroupActivitiesUseCase>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return GetGroupActivitiesUseCase(repository: repository);
});

// ============================================================================
// Notifiers
// ============================================================================

/// Notifier managing the paginated activity feed for a specific group.
class GroupActivityNotifier extends FamilyAsyncNotifier<ActivityFeed, String> {
  @override
  FutureOr<ActivityFeed> build(String groupId) {
    final isAuthenticated = ref.watch(authStateProvider);
    if (!isAuthenticated) {
      return ActivityFeed(
        groupId: groupId,
        items: const [],
        page: 1,
        limit: 0,
        totalPages: 1,
        totalItems: 0,
      );
    }
    final useCase = ref.watch(getGroupActivitiesUseCaseProvider);
    return useCase(groupId: groupId, page: 1);
  }

  /// Loads the next page of activities for this group.
  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (state.isLoading || current == null || !current.hasMore) {
      return;
    }

    final nextPage = current.page + 1;
    final useCase = ref.read(getGroupActivitiesUseCaseProvider);

    try {
      final newResult = await useCase(
        groupId: arg,
        page: nextPage,
        limit: current.limit,
      );

      state = AsyncData(ActivityFeed(
        groupId: arg,
        items: [...current.items, ...newResult.items],
        page: nextPage,
        limit: newResult.limit,
        totalPages: newResult.totalPages,
        totalItems: newResult.totalItems,
      ));
    } catch (e) {
      rethrow;
    }
  }

  /// Refreshes the activity feed by invalidating itself.
  void refresh() {
    ref.invalidateSelf();
  }
}

/// Family provider exposing the paginated activity feed.
final groupActivityProvider =
    AsyncNotifierProvider.family<GroupActivityNotifier, ActivityFeed, String>(() {
  return GroupActivityNotifier();
});
