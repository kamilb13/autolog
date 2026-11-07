import '../../core/utils/formatters.dart';
import '../../domain/models/buyer_report.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/tco_stats.dart';
import 'expense_repository.dart';
import 'vehicle_repository.dart';

class StatsRepository {
  final ExpenseRepository _expenseRepository;
  final VehicleRepository _vehicleRepository;

  StatsRepository({
    ExpenseRepository? expenseRepository,
    VehicleRepository? vehicleRepository,
  }) : _expenseRepository = expenseRepository ?? ExpenseRepository(),
       _vehicleRepository = vehicleRepository ?? VehicleRepository();

  Future<TcoStats> getTcoStats(String? vehicleId) async {
    final expenses = await _expenseRepository.getExpenses(vehicleId: vehicleId);
    final vehicles = await _vehicleRepository.getAllVehicles();

    if (expenses.isEmpty) {
      return TcoStats(
        vehicleId: vehicleId,
        totalCostPln: 0.0,
        costPerKmPln: 0.0,
        totalEntries: 0,
        categoryBreakdown: [],
      );
    }

    final double totalCost = expenses.fold(0.0, (sum, e) => sum + e.amountPln);
    final int totalEntries = expenses.length;

    // Calculate cost per km
    double costPerKm = 0.0;
    if (vehicleId != null && vehicleId.isNotEmpty) {
      final vehicle = vehicles.where((v) => v.id == vehicleId).firstOrNull;
      if (vehicle != null && vehicle.mileageKm > 0) {
        final mileages = expenses
            .map((e) => e.mileageKm)
            .whereType<int>()
            .where((km) => km > 0)
            .toList();
        if (mileages.isNotEmpty) {
          mileages.sort();
          final delta = mileages.last - mileages.first;
          if (delta > 0) {
            costPerKm = totalCost / delta;
          } else {
            costPerKm = totalCost / vehicle.mileageKm;
          }
        } else {
          costPerKm = totalCost / vehicle.mileageKm;
        }
      }
    } else {
      final totalMileage = vehicles.fold(0, (sum, v) => sum + v.mileageKm);
      if (totalMileage > 0) {
        costPerKm = totalCost / totalMileage;
      }
    }

    // Category breakdown
    final Map<ExpenseCategory, double> sums = {};
    final Map<ExpenseCategory, int> counts = {};

    for (final exp in expenses) {
      sums[exp.category] = (sums[exp.category] ?? 0.0) + exp.amountPln;
      counts[exp.category] = (counts[exp.category] ?? 0) + 1;
    }

    final List<CategoryBreakdownItem> breakdown = ExpenseCategory.values
        .where((cat) => (sums[cat] ?? 0.0) > 0)
        .map((cat) {
          final amount = sums[cat] ?? 0.0;
          final percentage = totalCost > 0 ? (amount / totalCost) : 0.0;
          return CategoryBreakdownItem(
            category: cat,
            totalAmountPln: amount,
            percentage: percentage,
            count: counts[cat] ?? 0,
          );
        })
        .toList();

    breakdown.sort((a, b) => b.totalAmountPln.compareTo(a.totalAmountPln));

    return TcoStats(
      vehicleId: vehicleId,
      totalCostPln: totalCost,
      costPerKmPln: costPerKm,
      totalEntries: totalEntries,
      categoryBreakdown: breakdown,
    );
  }

  Future<BuyerReport?> getBuyerReport(String vehicleId) async {
    final vehicle = await _vehicleRepository.getVehicleById(vehicleId);
    if (vehicle == null) return null;

    final expenses = await _expenseRepository.getExpenses(vehicleId: vehicleId);
    return BuyerReport(
      vehicle: vehicle,
      generatedAt: AppFormatters.formatDate(DateTime.now()),
      expenses: expenses,
    );
  }
}
