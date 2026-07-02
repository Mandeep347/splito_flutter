import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/pairwise_balance.dart';

part 'pairwise_balance_model.freezed.dart';
part 'pairwise_balance_model.g.dart';

/// Data model representing a pairwise balance with JSON serialization support.
@freezed
class PairwiseBalanceModel with _$PairwiseBalanceModel {
  /// Constructor for [PairwiseBalanceModel].
  const factory PairwiseBalanceModel({
    @JsonKey(name: 'from_user_id') required String fromUserId,
    @JsonKey(name: 'from_user_name') required String fromUserName,
    @JsonKey(name: 'to_user_id') required String toUserId,
    @JsonKey(name: 'to_user_name') required String toUserName,
    required String amount,
    required String currency,
  }) = _PairwiseBalanceModel;

  const PairwiseBalanceModel._();

  /// Creates a [PairwiseBalanceModel] from a JSON map.
  factory PairwiseBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$PairwiseBalanceModelFromJson(json);

  /// Converts this model into a domain [PairwiseBalance] entity.
  PairwiseBalance toEntity() {
    return PairwiseBalance(
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toUserId: toUserId,
      toUserName: toUserName,
      amount: double.parse(amount),
      currency: currency,
    );
  }
}
