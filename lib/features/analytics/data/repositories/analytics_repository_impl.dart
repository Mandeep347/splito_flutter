import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/group_analytics.dart';
import '../../domain/entities/user_analytics.dart';
import '../../domain/repositories/i_analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

/// Implementation of the domain [IAnalyticsRepository] contract.
class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  /// The remote datasource dependency.
  final IAnalyticsRemoteDatasource datasource;

  /// Creates a new [AnalyticsRepositoryImpl] instance.
  const AnalyticsRepositoryImpl({required this.datasource});

  @override
  Future<GroupAnalytics> getGroupAnalytics(String groupId) async {
    final model = await datasource.getGroupAnalytics(groupId);
    return model.toEntity();
  }

  @override
  Future<UserAnalytics> getUserAnalytics() async {
    final model = await datasource.getUserAnalytics();
    return model.toEntity();
  }
}

/// Provider exposing [IAnalyticsRepository] implementation.
final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  final datasource = ref.watch(analyticsRemoteDatasourceProvider);
  return AnalyticsRepositoryImpl(datasource: datasource);
});
