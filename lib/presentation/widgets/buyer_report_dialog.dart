import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/formatters.dart';
import '../../data/services/pdf_report_service.dart';
import '../../domain/models/buyer_report.dart';

class BuyerReportDialog extends StatefulWidget {
  final BuyerReport report;
  final VoidCallback onDismiss;

  const BuyerReportDialog({
    super.key,
    required this.report,
    required this.onDismiss,
  });

  @override
  State<BuyerReportDialog> createState() => _BuyerReportDialogState();
}

class _BuyerReportDialogState extends State<BuyerReportDialog> {
  bool _isGeneratingPdf = false;

  Future<void> _handlePdfPreview() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfReportService.printOrPreview(widget.report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd generowania PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _handlePdfShare() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfReportService.sharePdf(widget.report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd udostępniania PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _shareText(BuildContext context) {
    Share.share(
      widget.report.formattedSummary,
      subject: 'Raport Serwisowy — ${widget.report.vehicle.brand} ${widget.report.vehicle.model}',
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.report.formattedSummary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tekst raportu skopiowany do schowka!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicle = widget.report.vehicle;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raport Pojazdu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Historia serwisowa i dokument sprzedaży',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: widget.onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

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
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                            'Nr rej.: ${vehicle.licensePlate} • Rocznik: ${vehicle.year} • ${vehicle.fuelType}',
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
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Przebieg: ${AppFormatters.mileage(vehicle.mileageKm)}',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Wydatki: ${AppFormatters.currency(widget.report.totalCostPln)}',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Expenses items list
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Zarejestrowane pozycje (${widget.report.totalExpensesCount})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '${widget.report.expenses.length} pozycji w raporcie',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 6),

                    if (widget.report.expenses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Brak wpisów dla tego pojazdu.')),
                      )
                    else
                      ...widget.report.expenses.map((exp) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      exp.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                              const Divider(height: 10),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Primary PDF Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingPdf ? null : _handlePdfPreview,
                    icon: _isGeneratingPdf
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Podgląd / Drukuj PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingPdf ? null : _handlePdfShare,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Udostępnij PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Secondary Text Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Kopiuj tekst', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => _shareText(context),
                  icon: const Icon(Icons.text_snippet_rounded, size: 14),
                  label: const Text('Udostępnij tekst', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
