import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:splito_flutter/features/expenses/domain/entities/expense_participant.dart';

part 'expense_participant_model.freezed.dart';
part 'expense_participant_model.g.dart';

/// Serialization model representing an expense participant response.
@freezed
class ExpenseParticipantModel with _$ExpenseParticipantModel {
  /// Creates a new [ExpenseParticipantModel] instance.
  const factory ExpenseParticipantModel({
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'owed_amount') required String owedAmount,
    String? percentage,
    int? shares,
  }) = _ExpenseParticipantModel;

  const ExpenseParticipantModel._();

  /// Deserializes a JSON map into an [ExpenseParticipantModel].
  factory ExpenseParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseParticipantModelFromJson(json);

  /// Converts this serialization model into a domain [ExpenseParticipant] entity.
  ExpenseParticipant toEntity() {
    return ExpenseParticipant(
      userId: userId,
      name: name,
      owedAmount: double.parse(owedAmount),
      percentage: percentage != null ? double.parse(percentage!) : null,
      shares: shares,
    );
  }
}
