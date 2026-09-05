import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vehicle.dart';
import '../providers/app_providers.dart';
import '../widgets/reminder_card.dart';
import 'add_reminder_dialog.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remindersState = ref.watch(remindersNotifierProvider);
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terminy i Przypomnienia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              remindersState.urgentCount > 0
                  ? '${remindersState.urgentCount} pilne alerty do wykonania'
                  : 'Wszystkie terminy pod kontrolą',
              style: TextStyle(
                fontSize: 12,
                color: remindersState.urgentCount > 0 ? Colors.red : Colors.grey.shade600,
                fontWeight: remindersState.urgentCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Odśwież',
            onPressed: () => ref.read(remindersNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddReminderDialog(),
          );
        },
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Nowy termin', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Szukaj przypomnienia...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(remindersNotifierProvider.notifier).setSearchQuery('');
                      },
                    )
                  : null,
            ),
            onChanged: (q) => ref.read(remindersNotifierProvider.notifier).setSearchQuery(q),
          ),
          const SizedBox(height: 12),

          // Vehicle Filter Chips
          vehiclesAsync.when(
            data: (vehicles) {
              if (vehicles.length <= 1) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          selected: remindersState.selectedVehicleId == null,
                          label: const Text('Wszystkie auta'),
                          onSelected: (_) => ref
                              .read(remindersNotifierProvider.notifier)
                              .setVehicleFilter(null),
                        ),
                      ),
                      ...vehicles.map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            selected: remindersState.selectedVehicleId == v.id,
                            label: Text('${v.brand} ${v.model}'),
                            onSelected: (_) => ref
                                .read(remindersNotifierProvider.notifier)
                                .setVehicleFilter(v.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Severity Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: remindersState.selectedSeverity == null,
                    showCheckmark: false,
                    label: const Text('Wszystkie'),
                    onSelected: (_) => ref
                        .read(remindersNotifierProvider.notifier)
                        .setSeverityFilter(null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: remindersState.selectedSeverity == AlertSeverity.critical,
                    showCheckmark: false,
                    label: const Text('Krytyczne'),
                    avatar: Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade700),
                    onSelected: (selected) {
                      ref
                          .read(remindersNotifierProvider.notifier)
                          .setSeverityFilter(selected ? AlertSeverity.critical : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: remindersState.selectedSeverity == AlertSeverity.warning,
                    showCheckmark: false,
                    label: const Text('Ostrzeżenia'),
                    avatar: Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                    onSelected: (selected) {
                      ref
                          .read(remindersNotifierProvider.notifier)
                          .setSeverityFilter(selected ? AlertSeverity.warning : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: remindersState.selectedSeverity == AlertSeverity.info,
                    showCheckmark: false,
                    label: const Text('Informacyjne'),
                    avatar: Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade700),
                    onSelected: (selected) {
                      ref
                          .read(remindersNotifierProvider.notifier)
                          .setSeverityFilter(selected ? AlertSeverity.info : null);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Reminders list
          if (remindersState.reminders.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Brak aktywnych przypomnień',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wszystkie pozycje są zrealizowane lub dodaj nowy termin.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            vehiclesAsync.when(
              data: (vehicles) {
                return Column(
                  children: remindersState.reminders.map((reminder) {
                    final vehicle = vehicles.where((v) => v.id == reminder.vehicleId).firstOrNull;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ReminderCard(
                        reminder: reminder,
                        vehicle: vehicle,
                        onMarkCompleted: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await ref
                              .read(remindersNotifierProvider.notifier)
                              .markCompleted(reminder.id);
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Oznaczono jako wykonane: ${reminder.title}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        onDelete: () async {
                          final deletedReminder = reminder;
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.hideCurrentSnackBar();

                          await ref
                              .read(remindersNotifierProvider.notifier)
                              .deleteReminder(deletedReminder.id);

                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Usunięto przypomnienie: ${deletedReminder.title}'),
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: 'COFNIJ',
                                  textColor: Colors.amberAccent,
                                  onPressed: () async {
                                    await ref
                                        .read(remindersNotifierProvider.notifier)
                                        .addReminder(deletedReminder);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Błąd: $err'),
            ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}
