import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/group_balances.dart';
import 'pairwise_balance_model.dart';

part 'group_balances_model.freezed.dart';
part 'group_balances_model.g.dart';

/// Data model representing a group's balances with JSON serialization support.
@freezed
class GroupBalancesModel with _$GroupBalancesModel {
  /// Constructor for [GroupBalancesModel].
  const factory GroupBalancesModel({
    @JsonKey(name: 'group_id') required String groupId,
    required String currency,
    required List<PairwiseBalanceModel> balances,
  }) = _GroupBalancesModel;

  const GroupBalancesModel._();

  /// Creates a [GroupBalancesModel] from a JSON map.
  factory GroupBalancesModel.fromJson(Map<String, dynamic> json) =>
      _$GroupBalancesModelFromJson(json);

  /// Converts this model into a domain [GroupBalances] entity.
  GroupBalances toEntity() {
    return GroupBalances(
      groupId: groupId,
      currency: currency,
      balances: balances.map((b) => b.toEntity()).toList(),
    );
  }
}
