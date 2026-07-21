import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/member_contribution.dart';

part 'member_contribution_model.freezed.dart';
part 'member_contribution_model.g.dart';

/// Serialization model representing a member's contribution breakdown response.
@freezed
class MemberContributionModel with _$MemberContributionModel {
  /// Creates a new [MemberContributionModel] instance.
  const factory MemberContributionModel({
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'total_paid') required String totalPaid,
    @JsonKey(name: 'total_owed') required String totalOwed,
    @JsonKey(name: 'net_balance') required String netBalance,
    @JsonKey(name: 'expense_count') required int expenseCount,
    @JsonKey(name: 'percentage_of_total') required String percentageOfTotal,
  }) = _MemberContributionModel;

  const MemberContributionModel._();

  /// Deserializes a JSON map into a [MemberContributionModel].
  factory MemberContributionModel.fromJson(Map<String, dynamic> json) =>
      _$MemberContributionModelFromJson(json);

  /// Converts this serialization model into a domain [MemberContribution] entity.
  MemberContribution toEntity() {
    return MemberContribution(
      userId: userId,
      name: name,
      totalPaid: double.parse(totalPaid),
      totalOwed: double.parse(totalOwed),
      netBalance: double.parse(netBalance),
      expenseCount: expenseCount,
      percentageOfTotal: double.parse(percentageOfTotal),
    );
  }
}
