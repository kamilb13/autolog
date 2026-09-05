import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/buyer_report.dart';

class BuyerReportDialog extends StatelessWidget {
  final BuyerReport report;
  final VoidCallback onDismiss;

  const BuyerReportDialog({
    super.key,
    required this.report,
    required this.onDismiss,
  });

  void _shareReport(BuildContext context) {
    Share.share(
      report.formattedSummary,
      subject: 'Raport Serwisowy — ${report.vehicle.brand} ${report.vehicle.model}',
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: report.formattedSummary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Raport skopiowany do schowka!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicle = report.vehicle;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.description_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Raport dla Kupującego',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle details banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.brand} ${vehicle.model} ${vehicle.generationOrTrim}'.trim(),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nr rej.: ${vehicle.licensePlate} • Rocznik: ${vehicle.year}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                          if (vehicle.vin.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'VIN: ${vehicle.vin}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            'Aktualny przebieg: ${AppFormatters.mileage(vehicle.mileageKm)}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Stats summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Historia serwisowa (${report.totalExpensesCount} pozycji)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Suma: ${AppFormatters.currency(report.totalCostPln)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Expenses items list
                    if (report.expenses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Brak wpisów dla tego pojazdu.')),
                      )
                    else
                      ...report.expenses.map((exp) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      exp.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    AppFormatters.currency(exp.amountPln),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    AppFormatters.formatDisplayDate(exp.date),
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                                  Text(
                                    AppFormatters.mileage(exp.mileageKm),
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  if (exp.workshopOrLocation != null && exp.workshopOrLocation!.isNotEmpty) ...[
                                    Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                                    Expanded(
                                      child: Text(
                                        exp.workshopOrLocation!,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (exp.note != null && exp.note!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  exp.note!,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                ),
                              ],
                              const Divider(height: 12),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Actions: Copy / Share
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Kopiuj'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareReport(context),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Udostępnij raport'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
