import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_analytics_group.dart';

part 'user_analytics_group_model.freezed.dart';
part 'user_analytics_group_model.g.dart';

/// Serialization model representing individual group spendings inside personal analytics.
@freezed
class UserAnalyticsGroupModel with _$UserAnalyticsGroupModel {
  /// Creates a new [UserAnalyticsGroupModel] instance.
  const factory UserAnalyticsGroupModel({
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'group_name') required String groupName,
    @JsonKey(name: 'total_spent') required String totalSpent,
    @JsonKey(name: 'user_paid') required String userPaid,
    @JsonKey(name: 'user_owed') required String userOwed,
    @JsonKey(name: 'expense_count') required int expenseCount,
    required String currency,
  }) = _UserAnalyticsGroupModel;

  const UserAnalyticsGroupModel._();

  /// Deserializes a JSON map into a [UserAnalyticsGroupModel].
  factory UserAnalyticsGroupModel.fromJson(Map<String, dynamic> json) =>
      _$UserAnalyticsGroupModelFromJson(json);

  /// Converts this serialization model into a domain [UserAnalyticsGroup] entity.
  UserAnalyticsGroup toEntity() {
    return UserAnalyticsGroup(
      groupId: groupId,
      groupName: groupName,
      totalSpent: double.parse(totalSpent),
      userPaid: double.parse(userPaid),
      userOwed: double.parse(userOwed),
      expenseCount: expenseCount,
      currency: currency,
    );
  }
}
