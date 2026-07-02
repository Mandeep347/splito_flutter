import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_overall_balance.dart';

part 'user_overall_balance_model.freezed.dart';
part 'user_overall_balance_model.g.dart';

/// Data model representing a user's overall balance with JSON serialization support.
@freezed
class UserOverallBalanceModel with _$UserOverallBalanceModel {
  /// Constructor for [UserOverallBalanceModel].
  const factory UserOverallBalanceModel({
    @JsonKey(name: 'counterpart_user_id') required String counterpartUserId,
    @JsonKey(name: 'counterpart_name') required String counterpartName,
    @JsonKey(name: 'net_amount') required String netAmount,
    required String currency,
  }) = _UserOverallBalanceModel;

  const UserOverallBalanceModel._();

  /// Creates a [UserOverallBalanceModel] from a JSON map.
  factory UserOverallBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$UserOverallBalanceModelFromJson(json);

  /// Converts this model into a domain [UserOverallBalance] entity.
  UserOverallBalance toEntity() {
    return UserOverallBalance(
      counterpartUserId: counterpartUserId,
      counterpartName: counterpartName,
      netAmount: double.parse(netAmount),
      currency: currency,
    );
  }
}
