import 'expense.dart';

class ExpenseSuggestion {
  final String title;
  final ExpenseCategory category;
  final bool isCustom;
  final int count;

  const ExpenseSuggestion({
    required this.title,
    required this.category,
    this.isCustom = false,
    this.count = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseSuggestion &&
          runtimeType == other.runtimeType &&
          title.toLowerCase() == other.title.toLowerCase() &&
          category == other.category;

  @override
  int get hashCode => title.toLowerCase().hashCode ^ category.hashCode;

  @override
  String toString() =>
      'ExpenseSuggestion(title: $title, category: ${category.displayName}, isCustom: $isCustom)';
}
