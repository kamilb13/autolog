import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/expense.dart';
import '../providers/app_providers.dart';
import '../widgets/polish_license_plate.dart';
import '../widgets/timeline_expense_item.dart';
import '../widgets/update_mileage_dialog.dart';
import 'add_expense_screen.dart';
import 'vehicle_settings_screen.dart';

class VehicleDashboardScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDashboardScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  ConsumerState<VehicleDashboardScreen> createState() => _VehicleDashboardScreenState();
}

class _VehicleDashboardScreenState extends ConsumerState<VehicleDashboardScreen> {
  ExpenseCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final expensesState = ref.watch(expensesNotifierProvider);
    final theme = Theme.of(context);

    return vehiclesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Błąd: $err')),
      ),
      data: (vehicles) {
        final vehicle = vehicles.where((v) => v.id == widget.vehicleId).firstOrNull;

        if (vehicle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Nie znaleziono wybranego pojazdu.')),
          );
        }

        // Filter expenses for this vehicle
        var vehicleExpenses = expensesState.expenses.where((e) => e.vehicleId == vehicle.id).toList();
        if (_selectedCategory != null) {
          vehicleExpenses = vehicleExpenses.where((e) => e.category == _selectedCategory).toList();
        }

        final double totalVehicleExpenses = expensesState.expenses
            .where((e) => e.vehicleId == vehicle.id)
            .fold(0.0, (sum, e) => sum + e.amountPln);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                Text(
                  'Pulpit Pojazdu',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: 'Ustawienia pojazdu',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VehicleSettingsScreen(vehicle: vehicle),
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(initialVehicleId: vehicle.id),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nowy wpis', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Dashboard Vehicle Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vehicle.brand} ${vehicle.model}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                              if (vehicle.generationOrTrim.isNotEmpty)
                                Text(
                                  '${vehicle.generationOrTrim} • ${vehicle.year}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                )
                              else
                                Text(
                                  'Rocznik: ${vehicle.year}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                          PolishLicensePlate(plateText: vehicle.licensePlate),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Mileage & Total Spent KPI
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => UpdateMileageDialog(
                                    currentMileageKm: vehicle.mileageKm,
                                    onConfirm: (newMileage) {
                                      ref
                                          .read(vehiclesNotifierProvider.notifier)
                                          .updateMileage(vehicle.id, newMileage);
                                    },
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.speed_rounded, size: 14, color: theme.colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'STAN LICZNIKA',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.edit_rounded, size: 13, color: theme.colorScheme.primary),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppFormatters.mileage(vehicle.mileageKm),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.receipt_long_rounded, size: 14, color: Colors.grey.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SUMA WYDATKÓW',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppFormatters.shortCurrency(totalVehicleExpenses),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Category Filter Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Oś czasu zdarzeń (${vehicleExpenses.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        selected: _selectedCategory == null,
                        label: const Text('Wszystkie'),
                        onSelected: (_) => setState(() => _selectedCategory = null),
                      ),
                    ),
                    ...ExpenseCategory.values.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          selected: _selectedCategory == cat,
                          avatar: Icon(cat.icon, size: 15, color: _selectedCategory == cat ? null : cat.color),
                          label: Text(cat.displayName),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? cat : null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Timeline List
              if (vehicleExpenses.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        _selectedCategory == null
                            ? 'Brak zarejestrowanych wydatków dla tego pojazdu'
                            : 'Brak wpisów dla wybranej kategorii',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ...vehicleExpenses.map(
                  (exp) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TimelineExpenseItem(
                      expense: exp,
                      onDelete: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref.read(expensesNotifierProvider.notifier).deleteExpense(exp.id);
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Usunięto wpis "${exp.title}"')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 72),
            ],
          ),
        );
      },
    );
  }
}
