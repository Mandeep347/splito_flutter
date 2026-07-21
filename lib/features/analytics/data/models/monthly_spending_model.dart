import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/monthly_spending.dart';

part 'monthly_spending_model.freezed.dart';
part 'monthly_spending_model.g.dart';

/// Serialization model representing a monthly spending summary response.
@freezed
class MonthlySpendingModel with _$MonthlySpendingModel {
  /// Creates a new [MonthlySpendingModel] instance.
  const factory MonthlySpendingModel({
    required int year,
    required int month,
    @JsonKey(name: 'month_label') required String monthLabel,
    @JsonKey(name: 'total_amount') required String totalAmount,
    @JsonKey(name: 'expense_count') required int expenseCount,
  }) = _MonthlySpendingModel;

  const MonthlySpendingModel._();

  /// Deserializes a JSON map into a [MonthlySpendingModel].
  factory MonthlySpendingModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlySpendingModelFromJson(json);

  /// Converts this serialization model into a domain [MonthlySpending] entity.
  MonthlySpending toEntity({String currency = 'INR'}) {
    return MonthlySpending(
      year: year,
      month: month,
      monthLabel: monthLabel,
      totalAmount: double.parse(totalAmount),
      expenseCount: expenseCount,
      currency: currency,
    );
  }
}
