import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/buyer_report.dart';

class PdfReportService {
  static Future<Uint8List> generateBuyerReportPdf(BuyerReport report) async {
    final regular = await rootBundle.load(
      'assets/fonts/LiberationSans-Regular.ttf',
    );
    final bold = await rootBundle.load('assets/fonts/LiberationSans-Bold.ttf');
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(regular),
      bold: pw.Font.ttf(bold),
    );
    final pdf = pw.Document();
    final vehicle = report.vehicle;
    final entries = report.expenses;

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Text(
            'Historia serwisowa',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('AutoLog', style: const pw.TextStyle(fontSize: 8)),
              pw.Text(
                '${context.pageNumber} / ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
        build: (_) => [
          pw.Text(
            '${vehicle.brand} ${vehicle.model} ${vehicle.generationOrTrim}'
                .trim(),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Rok produkcji: ${vehicle.year}'),
          pw.Text('Nr rejestracyjny: ${vehicle.licensePlate}'),
          pw.Text('Stan licznika: ${AppFormatters.mileage(vehicle.mileageKm)}'),
          if (report.includeVin && vehicle.vin.isNotEmpty)
            pw.Text('VIN: ${vehicle.vin}'),
          pw.Text('Data raportu: ${report.generatedAt}'),
          pw.Text('Liczba wpisów: ${entries.length}'),
          pw.SizedBox(height: 16),
          if (entries.isEmpty) pw.Text('Brak wybranych wpisów.'),
          for (final entry in entries) ...[
            pw.Divider(color: PdfColors.grey400, thickness: 0.5),
            pw.Text(
              '${AppFormatters.formatDisplayDate(entry.date)} | '
              '${AppFormatters.mileage(entry.mileageKm)}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              entry.title,
              overflow: pw.TextOverflow.span,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            if (report.includeWorkshop &&
                (entry.workshopOrLocation?.isNotEmpty ?? false))
              pw.Text(
                'Warsztat / miejsce: ${entry.workshopOrLocation}',
                overflow: pw.TextOverflow.span,
                style: const pw.TextStyle(fontSize: 10),
              ),
            if (report.includeNotes && (entry.note?.isNotEmpty ?? false))
              pw.Text(
                entry.note!,
                overflow: pw.TextOverflow.span,
                style: const pw.TextStyle(fontSize: 10),
              ),
            if (report.includeCosts)
              pw.Text(
                'Koszt: ${AppFormatters.currency(entry.amountPln)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            pw.SizedBox(height: 8),
          ],
          if (report.includeCosts) ...[
            pw.Divider(color: PdfColors.grey400, thickness: 0.5),
            pw.Text(
              'Suma wybranych wpisów: ${AppFormatters.currency(report.totalCostPln)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ],
      ),
    );
    return pdf.save();
  }

  static String _filename(BuyerReport report) =>
      'Historia_${report.vehicle.brand}_${report.vehicle.model}.pdf'.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );

  static Future<void> printOrPreview(BuyerReport report) async {
    final bytes = await generateBuyerReportPdf(report);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _filename(report),
    );
  }

  static Future<void> sharePdf(BuyerReport report) async {
    final bytes = await generateBuyerReportPdf(report);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _filename(report),
      subject:
          'Historia serwisowa — ${report.vehicle.brand} ${report.vehicle.model}',
    );
  }
}
