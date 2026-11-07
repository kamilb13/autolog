import '../../core/utils/formatters.dart';
import 'expense.dart';
import 'vehicle.dart';

class BuyerReport {
  final Vehicle vehicle;
  final String generatedAt;
  final List<Expense> allExpenses;
  final Set<String>? selectedExpenseIds;
  final bool includeCosts;
  final bool includeWorkshop;
  final bool includeNotes;
  final bool includeVin;

  BuyerReport({
    required this.vehicle,
    required this.generatedAt,
    required List<Expense> expenses,
    Set<String>? selectedExpenseIds,
    this.includeCosts = false,
    this.includeWorkshop = true,
    this.includeNotes = true,
    this.includeVin = true,
  }) : allExpenses = List.unmodifiable(
         expenses.where((e) => e.vehicleId == vehicle.id).toList()..sort((
           a,
           b,
         ) {
           final aDate = AppFormatters.parseFlexibleDate(a.date) ?? DateTime(0);
           final bDate = AppFormatters.parseFlexibleDate(b.date) ?? DateTime(0);
           final byDate = bDate.compareTo(aDate);
           return byDate != 0
               ? byDate
               : (b.mileageKm ?? 0).compareTo(a.mileageKm ?? 0);
         }),
       ),
       selectedExpenseIds = selectedExpenseIds == null
           ? null
           : Set.unmodifiable(selectedExpenseIds);

  List<Expense> get expenses => allExpenses.where((expense) {
    return selectedExpenseIds?.contains(expense.id) ??
        (expense.category == ExpenseCategory.service ||
            expense.category == ExpenseCategory.parts);
  }).toList();

  int get totalExpensesCount => expenses.length;
  double get totalCostPln =>
      expenses.fold(0.0, (sum, expense) => sum + expense.amountPln);

  BuyerReport copyWith({
    Set<String>? selectedExpenseIds,
    bool? includeCosts,
    bool? includeWorkshop,
    bool? includeNotes,
    bool? includeVin,
  }) => BuyerReport(
    vehicle: vehicle,
    generatedAt: generatedAt,
    expenses: allExpenses,
    selectedExpenseIds: selectedExpenseIds ?? this.selectedExpenseIds,
    includeCosts: includeCosts ?? this.includeCosts,
    includeWorkshop: includeWorkshop ?? this.includeWorkshop,
    includeNotes: includeNotes ?? this.includeNotes,
    includeVin: includeVin ?? this.includeVin,
  );

  String get formattedSummary {
    final entries = expenses;
    final text = StringBuffer()
      ..writeln('Historia serwisowa')
      ..writeln(
        '${vehicle.brand} ${vehicle.model} ${vehicle.generationOrTrim}'.trim(),
      )
      ..writeln('Rok produkcji: ${vehicle.year}')
      ..writeln('Nr rejestracyjny: ${vehicle.licensePlate}')
      ..writeln('Stan licznika: ${AppFormatters.mileage(vehicle.mileageKm)}');
    if (includeVin && vehicle.vin.isNotEmpty) {
      text.writeln('VIN: ${vehicle.vin}');
    }
    text
      ..writeln('Data raportu: $generatedAt')
      ..writeln('Liczba wpisów: ${entries.length}')
      ..writeln();
    for (final entry in entries) {
      text.writeln(
        '${AppFormatters.formatDisplayDate(entry.date)} | '
        '${AppFormatters.mileage(entry.mileageKm)} | ${entry.title}',
      );
      if (includeWorkshop && (entry.workshopOrLocation?.isNotEmpty ?? false)) {
        text.writeln('Warsztat / miejsce: ${entry.workshopOrLocation}');
      }
      if (includeNotes && (entry.note?.isNotEmpty ?? false)) {
        text.writeln(entry.note);
      }
      if (includeCosts) {
        text.writeln('Koszt: ${AppFormatters.currency(entry.amountPln)}');
      }
      text.writeln();
    }
    if (includeCosts) {
      text.writeln(
        'Suma wybranych wpisów: ${AppFormatters.currency(totalCostPln)}',
      );
    }
    return text.toString();
  }
}
