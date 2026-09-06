import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:autolog/l10n/app_localizations.dart';
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
          SnackBar(content: Text('Błąd PDF: $e')),
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
          SnackBar(content: Text('Błąd PDF: $e')),
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
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: widget.report.formattedSummary));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.reportCopiedMsg ?? 'Tekst raportu skopiowany do schowka!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vehicle = widget.report.vehicle;
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: mediaQuery.size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.reportTitle ?? 'Raport Pojazdu',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l10n?.reportSubtitle ?? 'Historia serwisowa i dokument sprzedaży',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
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

            // 2. Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.brand} ${vehicle.model} ${vehicle.generationOrTrim}'.trim(),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          // Badges wrap
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildInfoChip(context, Icons.badge_outlined, vehicle.licensePlate),
                              _buildInfoChip(context, Icons.calendar_today_outlined, vehicle.year.toString()),
                              _buildInfoChip(context, Icons.local_gas_station_outlined, vehicle.fuelType),
                              if (vehicle.vin.isNotEmpty)
                                _buildInfoChip(context, Icons.pin_outlined, 'VIN: ${vehicle.vin}', isMonospace: true),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // KPI summary row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.dashboardMileageKpi ?? 'LICZNIK',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppFormatters.mileage(vehicle.mileageKm),
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 28,
                                width: 1,
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.dashboardExpensesKpi ?? 'WYDATKI',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppFormatters.currency(widget.report.totalCostPln),
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                    const SizedBox(height: 16),

                    // Entries section title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.reportRegisteredEntries(widget.report.totalExpensesCount) ??
                              'Zarejestrowane pozycje (${widget.report.totalExpensesCount})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        Text(
                          l10n?.reportEntriesCount(widget.report.expenses.length) ??
                              '${widget.report.expenses.length} pozycji',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (widget.report.expenses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            l10n?.reportNoEntries ?? 'Brak wpisów dla tego pojazdu.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                      )
                    else
                      ...widget.report.expenses.map((exp) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      exp.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppFormatters.currency(exp.amountPln),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    AppFormatters.formatDisplayDate(exp.date),
                                    style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                  ),
                                  if (exp.mileageKm != null) ...[
                                    Text('•', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                                    Text(
                                      AppFormatters.mileage(exp.mileageKm),
                                      style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                  if (exp.workshopOrLocation != null && exp.workshopOrLocation!.isNotEmpty) ...[
                                    Text('•', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                                    Text(
                                      exp.workshopOrLocation!,
                                      style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ],
                              ),
                              if (exp.note != null && exp.note!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  exp.note!,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Primary PDF Actions: "Podgląd" and "Udostępnij"
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
                        : const Icon(Icons.visibility_rounded, size: 18),
                    label: Text(
                      l10n?.reportPrintPdf ?? 'Podgląd',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _isGeneratingPdf ? null : _handlePdfShare,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(
                      l10n?.reportSharePdf ?? 'Udostępnij',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 4. Secondary Text Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: Text(l10n?.reportCopyText ?? 'Kopiuj tekst', style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _shareText(context),
                  icon: const Icon(Icons.text_snippet_rounded, size: 14),
                  label: Text(l10n?.reportShareText ?? 'Udostępnij tekst', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, {bool isMonospace = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
