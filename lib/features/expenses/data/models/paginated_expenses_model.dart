import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:splito_flutter/features/expenses/domain/entities/paginated_expenses.dart';
import 'expense_model.dart';

part 'paginated_expenses_model.freezed.dart';
part 'paginated_expenses_model.g.dart';

/// Serialization model representing a paginated expense response.
@freezed
class PaginatedExpensesModel with _$PaginatedExpensesModel {
  /// Creates a new [PaginatedExpensesModel] instance.
  const factory PaginatedExpensesModel({
    required List<ExpenseModel> items,
    required int page,
    required int limit,
    @JsonKey(name: 'total_pages') required int totalPages,
    @JsonKey(name: 'total_items') required int totalItems,
  }) = _PaginatedExpensesModel;

  const PaginatedExpensesModel._();

  /// Deserializes a JSON map into a [PaginatedExpensesModel].
  factory PaginatedExpensesModel.fromJson(Map<String, dynamic> json) =>
      _$PaginatedExpensesModelFromJson(json);

  /// Converts this serialization model into a domain [PaginatedExpenses] entity.
  PaginatedExpenses toEntity() {
    return PaginatedExpenses(
      items: items.map((e) => e.toEntity()).toList(),
      page: page,
      limit: limit,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }
}
