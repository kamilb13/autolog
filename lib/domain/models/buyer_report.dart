import 'expense.dart';
import 'tco_stats.dart';
import 'vehicle.dart';

class BuyerReport {
  final Vehicle vehicle;
  final String generatedAt;
  final int totalExpensesCount;
  final double totalCostPln;
  final List<Expense> expenses;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final String formattedSummary;

  const BuyerReport({
    required this.vehicle,
    required this.generatedAt,
    required this.totalExpensesCount,
    required this.totalCostPln,
    required this.expenses,
    required this.categoryBreakdown,
    required this.formattedSummary,
  });
}
