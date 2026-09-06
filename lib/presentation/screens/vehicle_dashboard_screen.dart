import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/expense.dart';
import 'package:autolog/l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/polish_license_plate.dart';
import '../widgets/reminder_card.dart';
import '../widgets/timeline_expense_item.dart';
import '../widgets/update_mileage_dialog.dart';
import 'add_expense_screen.dart';
import 'add_reminder_dialog.dart';
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

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Skopiowano $label: $text',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final expensesState = ref.watch(expensesNotifierProvider);
    final remindersState = ref.watch(remindersNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return vehiclesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('${l10n?.commonError ?? "Błąd"}: $err')),
      ),
      data: (vehicles) {
        final vehicle = vehicles.where((v) => v.id == widget.vehicleId).firstOrNull;

        if (vehicle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Nie znaleziono wybranego pojazdu.')),
          );
        }

        // Active reminders for this vehicle
        final vehicleReminders = remindersState.reminders
            .where((r) => r.vehicleId == vehicle.id && !r.isCompleted)
            .toList();

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
                  l10n?.dashboardTitle ?? 'Pulpit Pojazdu',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: l10n?.dashboardSettingsTooltip ?? 'Ustawienia pojazdu',
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
            label: Text(l10n?.dashboardNewExpense ?? 'Nowy wydatek', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Dashboard Vehicle Header Card
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vehicle.brand} ${vehicle.model}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicle.generationOrTrim.isNotEmpty
                                    ? '${vehicle.generationOrTrim} • ${vehicle.year} • ${vehicle.fuelType}'
                                    : 'Rocznik: ${vehicle.year} • ${vehicle.fuelType}',
                                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Kliknij, aby skopiować nr rejestracyjny',
                          child: PolishLicensePlate(
                            plateText: vehicle.licensePlate,
                            scale: 0.95,
                            onTap: () => _copyToClipboard(
                              context,
                              vehicle.licensePlate,
                              'numer rejestracyjny',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // VIN Row / Chip
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (vehicle.vin.trim().isNotEmpty) {
                            _copyToClipboard(context, vehicle.vin.trim(), 'numer VIN');
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VehicleSettingsScreen(vehicle: vehicle),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                size: 14,
                                color: theme.colorScheme.primary.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vehicle.vin.trim().isNotEmpty
                                    ? 'VIN: ${vehicle.vin.trim()}'
                                    : 'VIN: Brak (kliknij, aby dodać)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: vehicle.vin.trim().isNotEmpty ? 'monospace' : null,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: vehicle.vin.trim().isNotEmpty ? 0.6 : 0,
                                  color: vehicle.vin.trim().isNotEmpty
                                      ? theme.colorScheme.onSurface.withValues(alpha: 0.85)
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                vehicle.vin.trim().isNotEmpty ? Icons.copy_rounded : Icons.edit_rounded,
                                size: 13,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                    const SizedBox(height: 14),

                    // Mileage & Total Spent & Purchase Price KPI
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.25 : 0.35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.speed_rounded, size: 13, color: theme.colorScheme.primary),
                                      const SizedBox(width: 3),
                                      Text(
                                        l10n?.dashboardMileageKpi ?? 'LICZNIK',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.edit_rounded, size: 12, color: theme.colorScheme.primary),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppFormatters.mileage(vehicle.mileageKm, unit: settings.distanceUnit.label),
                                    style: TextStyle(
                                      fontSize: vehicle.purchasePricePln != null ? 14 : 16,
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.receipt_long_rounded, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                    const SizedBox(width: 3),
                                    Text(
                                      l10n?.dashboardExpensesKpi ?? 'WYDATKI',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppFormatters.shortCurrency(totalVehicleExpenses, currencyCode: settings.currency.code),
                                  style: TextStyle(
                                    fontSize: vehicle.purchasePricePln != null ? 14 : 16,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (vehicle.purchasePricePln != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                      const SizedBox(width: 3),
                                      Text(
                                        l10n?.dashboardPurchaseKpi ?? 'ZAKUP',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppFormatters.shortCurrency(vehicle.purchasePricePln!, currencyCode: settings.currency.code),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ALERTS & REMINDERS SECTION (Visible in Dashboard!)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        vehicleReminders.isNotEmpty
                            ? Icons.notifications_active_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 18,
                        color: vehicleReminders.isNotEmpty
                            ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100))
                            : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Alerty i terminy (${vehicleReminders.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddReminderDialog(
                          initialVehicleId: vehicle.id,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Dodaj termin', style: TextStyle(fontSize: 12.5)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (vehicleReminders.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.green.shade900 : Colors.green.shade50).withValues(alpha: isDark ? 0.2 : 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? Colors.green.shade700 : Colors.green.shade200).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Wszystkie serwisy i opłaty dla tego auta są aktualne',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...vehicleReminders.map(
                  (rem) => ReminderCard(
                    reminder: rem,
                    vehicle: vehicle,
                    onMarkCompleted: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ref.read(remindersNotifierProvider.notifier).markCompleted(rem.id);
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Oznaczono jako wykonane: ${rem.title}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    onDelete: () async {
                      final deletedReminder = rem;
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      await ref.read(remindersNotifierProvider.notifier).deleteReminder(deletedReminder.id);
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Usunięto przypomnienie: ${deletedReminder.title}'),
                            duration: const Duration(seconds: 5),
                            action: SnackBarAction(
                              label: 'COFNIJ',
                              textColor: Colors.black,
                              onPressed: () async {
                                await ref.read(remindersNotifierProvider.notifier).addReminder(deletedReminder);
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Category Filter Chips & Timeline
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
                        showCheckmark: false,
                        label: const Text('Wszystkie'),
                        onSelected: (_) => setState(() => _selectedCategory = null),
                      ),
                    ),
                    ...ExpenseCategory.values.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          selected: _selectedCategory == cat,
                          showCheckmark: false,
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
                        final deletedExpense = exp;
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();

                        await ref.read(expensesNotifierProvider.notifier).deleteExpense(deletedExpense.id);

                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Usunięto wpis "${deletedExpense.title}"'),
                              duration: const Duration(seconds: 5),
                              action: SnackBarAction(
                                label: 'COFNIJ',
                                textColor: Colors.black,
                                onPressed: () async {
                                  await ref.read(expensesNotifierProvider.notifier).addExpense(deletedExpense);
                                },
                              ),
                            ),
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
