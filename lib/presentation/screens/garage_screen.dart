import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/drive_sync_dialog.dart';
import '../widgets/garage_summary_banner.dart';
import '../widgets/update_mileage_dialog.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_dashboard_screen.dart';

class GarageScreen extends ConsumerWidget {
  final VoidCallback onNavigateToReminders;

  const GarageScreen({
    super.key,
    required this.onNavigateToReminders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Garaż',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Odśwież',
            onPressed: () => ref.read(vehiclesNotifierProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.backup_rounded),
            tooltip: 'Kopia zapasowa i przywracanie',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const DriveSyncDialog(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddVehicleScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Dodaj auto', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Wczytywanie pojazdów...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Błąd: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.read(vehiclesNotifierProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
        data: (vehicles) {
          final totalAlerts = vehicles.fold(0, (sum, v) => sum + v.alerts.length);

          if (vehicles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      size: 72,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Twój garaż jest pusty',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dodaj swój pierwszy samochód, aby zarządzać serwisem, wydatkami i terminami.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddVehicleScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Dodaj pierwsze auto'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(vehiclesNotifierProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                InkWell(
                  onTap: onNavigateToReminders,
                  borderRadius: BorderRadius.circular(20),
                  child: GarageSummaryBanner(
                    vehicleCount: vehicles.length,
                    activeAlertsCount: totalAlerts,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Twoje Pojazdy (${vehicles.length})',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...vehicles.map(
                  (vehicle) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VehicleCard(
                      vehicle: vehicle,
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VehicleDashboardScreen(vehicleId: vehicle.id),
                          ),
                        );
                      },
                      onUpdateMileageClick: () {
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
                    ),
                  ),
                ),
                const SizedBox(height: 72),
              ],
            ),
          );
        },
      ),
    );
  }
}
