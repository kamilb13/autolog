import 'expense.dart';

class CategoryBreakdownItem {
  final ExpenseCategory category;
  final double totalAmountPln;
  final double percentage; // 0.0 to 1.0
  final int count;

  const CategoryBreakdownItem({
    required this.category,
    required this.totalAmountPln,
    required this.percentage,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category.toDbString(),
      'total_amount_pln': totalAmountPln,
      'percentage': percentage,
      'count': count,
    };
  }
}

class TcoStats {
  final String? vehicleId;
  final double totalCostPln;
  final double costPerKmPln;
  final int totalEntries;
  final List<CategoryBreakdownItem> categoryBreakdown;

  const TcoStats({
    this.vehicleId,
    required this.totalCostPln,
    required this.costPerKmPln,
    required this.totalEntries,
    required this.categoryBreakdown,
  });

  static const TcoStats empty = TcoStats(
    vehicleId: null,
    totalCostPln: 0.0,
    costPerKmPln: 0.0,
    totalEntries: 0,
    categoryBreakdown: [],
  );
}
