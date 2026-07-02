import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/simplified_balances.dart';
import 'pairwise_balance_model.dart';

part 'simplified_balances_model.freezed.dart';
part 'simplified_balances_model.g.dart';

/// Data model representing a group's simplified balances with JSON serialization support.
@freezed
class SimplifiedBalancesModel with _$SimplifiedBalancesModel {
  /// Constructor for [SimplifiedBalancesModel].
  const factory SimplifiedBalancesModel({
    @JsonKey(name: 'group_id') required String groupId,
    required String currency,
    required List<PairwiseBalanceModel> transactions,
  }) = _SimplifiedBalancesModel;

  const SimplifiedBalancesModel._();

  /// Creates a [SimplifiedBalancesModel] from a JSON map.
  factory SimplifiedBalancesModel.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedBalancesModelFromJson(json);

  /// Converts this model into a domain [SimplifiedBalances] entity.
  SimplifiedBalances toEntity() {
    return SimplifiedBalances(
      groupId: groupId,
      currency: currency,
      transactions: transactions.map((t) => t.toEntity()).toList(),
    );
  }
}
