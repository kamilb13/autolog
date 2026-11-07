import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/formatters.dart';
import '../../data/services/pdf_report_service.dart';
import '../../domain/models/buyer_report.dart';
import '../../domain/models/expense.dart';

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
  late BuyerReport _report;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  Set<String> get _selectedIds => _report.expenses.map((e) => e.id).toSet();

  Future<void> _runPdf(Future<void> Function(BuyerReport) action) async {
    final report = _report;
    setState(() => _isGeneratingPdf = true);
    try {
      await action(report);
    } catch (error, stack) {
      debugPrint('PDF report failed: $error\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nie udało się utworzyć PDF. Spróbuj ponownie.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _report.vehicle;
    final selectedIds = _selectedIds;
    final canExport = selectedIds.isNotEmpty && !_isGeneratingPdf;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Raport dla kupującego',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${vehicle.brand} ${vehicle.model}'),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Zamknij',
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _report.allExpenses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategorie',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 6,
                            children: [
                              for (final category in ExpenseCategory.values)
                                if (_report.allExpenses.any(
                                  (e) => e.category == category,
                                ))
                                  FilterChip(
                                    label: Text(category.displayName),
                                    selected: _report.allExpenses
                                        .where((e) => e.category == category)
                                        .every(
                                          (e) => selectedIds.contains(e.id),
                                        ),
                                    onSelected: _isGeneratingPdf
                                        ? null
                                        : (selected) {
                                            final ids = _selectedIds;
                                            final categoryIds = _report
                                                .allExpenses
                                                .where(
                                                  (e) => e.category == category,
                                                )
                                                .map((e) => e.id);
                                            if (selected) {
                                              ids.addAll(categoryIds);
                                            } else {
                                              ids.removeAll(categoryIds);
                                            }
                                            setState(
                                              () => _report = _report.copyWith(
                                                selectedExpenseIds: ids,
                                              ),
                                            );
                                          },
                                  ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Kwoty i suma'),
                            value: _report.includeCosts,
                            onChanged: _isGeneratingPdf
                                ? null
                                : (value) => setState(
                                    () => _report = _report.copyWith(
                                      includeCosts: value,
                                    ),
                                  ),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Warsztat / miejsce'),
                            value: _report.includeWorkshop,
                            onChanged: _isGeneratingPdf
                                ? null
                                : (value) => setState(
                                    () => _report = _report.copyWith(
                                      includeWorkshop: value,
                                    ),
                                  ),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Notatki'),
                            value: _report.includeNotes,
                            onChanged: _isGeneratingPdf
                                ? null
                                : (value) => setState(
                                    () => _report = _report.copyWith(
                                      includeNotes: value,
                                    ),
                                  ),
                          ),
                          if (vehicle.vin.isNotEmpty)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('VIN'),
                              value: _report.includeVin,
                              onChanged: _isGeneratingPdf
                                  ? null
                                  : (value) => setState(
                                      () => _report = _report.copyWith(
                                        includeVin: value,
                                      ),
                                    ),
                            ),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Wybrane wpisy: ${selectedIds.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _isGeneratingPdf
                                    ? null
                                    : () => setState(() {
                                        _report = _report.copyWith(
                                          selectedExpenseIds: {},
                                        );
                                      }),
                                child: const Text('Odznacz wszystkie'),
                              ),
                            ],
                          ),
                          if (_report.allExpenses.isEmpty)
                            const Text('Brak wpisów dla tego pojazdu.')
                          else if (selectedIds.isEmpty)
                            const Text(
                              'Zaznacz wpisy, które chcesz dołączyć do raportu.',
                            ),
                          if (_report.includeCosts && selectedIds.isNotEmpty)
                            Text(
                              'Suma wybranych wpisów: ${AppFormatters.currency(_report.totalCostPln)}',
                            ),
                        ],
                      );
                    }
                    final entry = _report.allExpenses[index - 1];
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: selectedIds.contains(entry.id),
                      title: Text(entry.title),
                      subtitle: Text(
                        [
                          '${AppFormatters.formatDisplayDate(entry.date)} | ${AppFormatters.mileage(entry.mileageKm)}',
                          if (_report.includeWorkshop &&
                              (entry.workshopOrLocation?.isNotEmpty ?? false))
                            'Warsztat / miejsce: ${entry.workshopOrLocation}',
                          if (_report.includeNotes &&
                              (entry.note?.isNotEmpty ?? false))
                            entry.note!,
                          if (_report.includeCosts)
                            AppFormatters.currency(entry.amountPln),
                        ].join('\n'),
                      ),
                      onChanged: _isGeneratingPdf
                          ? null
                          : (selected) {
                              final ids = _selectedIds;
                              if (selected == true) {
                                ids.add(entry.id);
                              } else {
                                ids.remove(entry.id);
                              }
                              setState(
                                () => _report = _report.copyWith(
                                  selectedExpenseIds: ids,
                                ),
                              );
                            },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canExport
                          ? () => _runPdf(PdfReportService.printOrPreview)
                          : null,
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Podgląd PDF'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canExport
                          ? () => _runPdf(PdfReportService.sharePdf)
                          : null,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Udostępnij'),
                    ),
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: canExport
                        ? () async {
                            await Clipboard.setData(
                              ClipboardData(text: _report.formattedSummary),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Skopiowano tekst raportu.'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: const Text('Kopiuj tekst'),
                  ),
                  TextButton(
                    onPressed: canExport
                        ? () => Share.share(
                            _report.formattedSummary,
                            subject:
                                'Historia serwisowa — ${vehicle.brand} ${vehicle.model}',
                          )
                        : null,
                    child: const Text('Udostępnij tekst'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
