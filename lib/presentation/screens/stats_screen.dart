import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../providers/app_providers.dart';
import '../widgets/buyer_report_dialog.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsNotifierProvider);
    final statsNotifier = ref.read(statsNotifierProvider.notifier);
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final theme = Theme.of(context);

    final stats = statsState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statystyki i TCO',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Odśwież',
            onPressed: () => statsNotifier.refresh(),
          ),
        ],
      ),
      body: statsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => statsNotifier.refresh(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Vehicle Filter Chips
                  vehiclesAsync.when(
                    data: (vehicles) {
                      if (vehicles.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  selected: statsState.selectedVehicleId == null,
                                  showCheckmark: false,
                                  label: const Text('Wszystkie pojazdy'),
                                  onSelected: (_) => statsNotifier.selectVehicle(null),
                                ),
                              ),
                              ...vehicles.map(
                                (v) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    selected: statsState.selectedVehicleId == v.id,
                                    showCheckmark: false,
                                    label: Text('${v.brand} ${v.model}'),
                                    onSelected: (_) => statsNotifier.selectVehicle(v.id),
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

                  // TCO Elevated Hero Card
                  Card(
                    elevation: 2,
                    color: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
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
                                    'CAŁKOWITY KOSZT (TCO)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppFormatters.currency(stats.totalCostPln),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.analytics_rounded,
                                  size: 28,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.speed_rounded, size: 15, color: theme.colorScheme.onPrimaryContainer),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppFormatters.costPerKm(stats.costPerKmPln),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.receipt_long_rounded, size: 15, color: theme.colorScheme.onPrimaryContainer),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${stats.totalEntries} pozycji',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Breakdown & Chart Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Podział kosztów według kategorii',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          if (stats.categoryBreakdown.isNotEmpty && stats.totalCostPln > 0) ...[
                            // Pie chart
                            SizedBox(
                              height: 180,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: stats.categoryBreakdown.map((item) {
                                    final percentInt = (item.percentage * 100).toInt();
                                    return PieChartSectionData(
                                      color: item.category.color,
                                      value: item.totalAmountPln,
                                      title: '$percentInt%',
                                      radius: 45,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // List of categories with progress bars
                            ...stats.categoryBreakdown.map((item) {
                              final percentInt = (item.percentage * 100).toInt();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: item.category.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              item.category.displayName,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '$percentInt%',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppFormatters.currency(item.totalAmountPln),
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: item.percentage,
                                        minHeight: 6,
                                        backgroundColor: item.category.color.withValues(alpha: 0.15),
                                        valueColor: AlwaysStoppedAnimation(item.category.color),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ] else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Brak zarejestrowanych wydatków dla wybranego zakresu.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buyer Report Card
                  vehiclesAsync.when(
                    data: (vehicles) {
                      if (vehicles.isEmpty) return const SizedBox.shrink();

                      // Resolve which vehicle to report: either the selected vehicle or the first vehicle if only 1 exists
                      final targetVehicle = vehicles.where((v) => v.id == statsState.selectedVehicleId).firstOrNull ??
                          (vehicles.length == 1 ? vehicles.first : null);

                      if (targetVehicle == null) {
                        return Card(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Wybierz konkretne auto powyżej, aby wygenerować ustrukturyzowany Raport dla Kupującego.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Card(
                        elevation: 1,
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.description_rounded, color: theme.colorScheme.primary),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Raport dla kupującego',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          'Eksport historii dla ${targetVehicle.brand} ${targetVehicle.model}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Wygeneruj ustrukturyzowane podsumowanie wszystkich napraw, wymian i przeglądów na potrzeby sprzedaży pojazdu.',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: statsState.isGeneratingReport
                                    ? null
                                    : () async {
                                        await statsNotifier.generateBuyerReport(targetVehicle.id);
                                        final report = ref.read(statsNotifierProvider).buyerReport;
                                        if (report != null && context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => BuyerReportDialog(
                                              report: report,
                                              onDismiss: () {
                                                Navigator.of(context).pop();
                                                statsNotifier.dismissBuyerReport();
                                              },
                                            ),
                                          );
                                        }
                                      },
                                icon: statsState.isGeneratingReport
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.description_rounded, size: 18),
                                label: Text(statsState.isGeneratingReport ? 'Generowanie...' : 'Generuj raport pojazdu'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 72),
                ],
              ),
            ),
    );
  }
}
