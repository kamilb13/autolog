import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/expense.dart';

class ParsedReceiptData {
  final double? amount;
  final DateTime? date;
  final String? location;
  final String? suggestedTitle;
  final ExpenseCategory suggestedCategory;
  final String rawText;

  const ParsedReceiptData({
    this.amount,
    this.date,
    this.location,
    this.suggestedTitle,
    this.suggestedCategory = ExpenseCategory.tollsFees,
    required this.rawText,
  });

  bool get hasAnyData => amount != null || date != null || location != null || suggestedTitle != null;

  @override
  String toString() {
    return 'ParsedReceiptData(amount: $amount, date: $date, location: $location, title: $suggestedTitle, category: $suggestedCategory)';
  }
}

class ReceiptParser {
  static const List<String> _fuelBrands = [
    'PKN ORLEN',
    'ORLEN',
    'SHELL',
    'BP',
    'CIRCLE K',
    'STATOIL',
    'MOL',
    'MOYA',
    'AMIC',
    'AVIA',
    'AUCHAN',
    'LOTOS',
    'ARAL',
    'TOTAL',
    'CRG',
    'HUZAR',
    'PIEPRZYK',
  ];

  static const List<String> _serviceKeywords = [
    'AUTO SERWIS',
    'AUTOSERWIS',
    'SERWIS SAMOCHODOWY',
    'MECHANIKA POJAZDOWA',
    'WULKANIZACJA',
    'OPONY',
    'STACJA KONTROLI POJAZDÓW',
    'SKP',
    'INTER CARS',
    'AUTODOC',
    'NORAUTO',
    'FEU VERT',
  ];

  static ParsedReceiptData parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return const ParsedReceiptData(rawText: '');
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final amount = _extractAmount(lines, rawText);
    final date = _extractDate(rawText);
    final location = _extractLocation(lines, rawText);
    final categoryAndTitle = _detectCategoryAndTitle(rawText, location);

    return ParsedReceiptData(
      amount: amount,
      date: date,
      location: location,
      suggestedTitle: categoryAndTitle.$2,
      suggestedCategory: categoryAndTitle.$1,
      rawText: rawText,
    );
  }

  static double? _extractAmount(List<String> lines, String fullText) {
    // 1. Look for explicit total keywords (SUMA PLN, RAZEM, DO ZAPŁATY, etc.)
    final totalKeywords = RegExp(
      r'(SUMA\s*PLN|SUMA\s*:|SUMA|RAZEM\s*PLN|RAZEM\s*:|RAZEM|DO\s*ZAPŁATY|DO\s*ZAPLATY|TOTAL|KWOTA\s*PLN|WARTOŚĆ\s*BRUTTO|WARTOSC\s*BRUTTO|PŁATNOŚĆ\s*KARTĄ|PLATNOSC\s*KARTA|KARTA\s*:?|GOTÓWKA\s*:?|GOTOWKA\s*:?)',
      caseSensitive: false,
    );

    // Number matching pattern: 123,45 or 123.45 or 1 234,56
    final priceRegex = RegExp(r'(\d{1,5}(?:[\s.]\d{3})*[,\.]\d{2})');

    // Strategy A: Scan lines backwards for keywords (totals are almost always near the bottom)
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      if (totalKeywords.hasMatch(line)) {
        // Look for number in current line
        final matches = priceRegex.allMatches(line).toList();
        if (matches.isNotEmpty) {
          final val = _cleanAndParseDouble(matches.last.group(1));
          if (val != null && val > 0 && val < 500000) return val;
        }

        // If not found on the same line, check next line (line i+1)
        if (i + 1 < lines.length) {
          final nextMatches = priceRegex.allMatches(lines[i + 1]).toList();
          if (nextMatches.isNotEmpty) {
            final val = _cleanAndParseDouble(nextMatches.last.group(1));
            if (val != null && val > 0 && val < 500000) return val;
          }
        }
      }
    }

    // Strategy B: Fallback - look for the largest reasonable amount near the bottom half of the receipt
    final allAmounts = <double>[];
    for (final line in lines) {
      // Ignore VAT rates or tax percentage lines like "PTU A 23%"
      if (RegExp(r'(PTU|VAT|STAWKA|%\s*\d+)', caseSensitive: false).hasMatch(line)) {
        continue;
      }
      for (final match in priceRegex.allMatches(line)) {
        final val = _cleanAndParseDouble(match.group(1));
        if (val != null && val > 0 && val < 500000) {
          allAmounts.add(val);
        }
      }
    }

    if (allAmounts.isNotEmpty) {
      // Return the maximum amount found in the receipt (totals are highest values)
      return allAmounts.reduce((a, b) => a > b ? a : b);
    }

    return null;
  }

  static double? _cleanAndParseDouble(String? raw) {
    if (raw == null) return null;
    var clean = raw.replaceAll(' ', '');
    if (clean.contains(',') && clean.contains('.')) {
      if (clean.lastIndexOf(',') > clean.lastIndexOf('.')) {
        clean = clean.replaceAll('.', '').replaceAll(',', '.');
      } else {
        clean = clean.replaceAll(',', '');
      }
    } else if (clean.contains(',')) {
      clean = clean.replaceAll(',', '.');
    }
    return double.tryParse(clean);
  }

  static DateTime? _extractDate(String fullText) {
    // Regex for: YYYY-MM-DD, YYYY.MM.DD, DD-MM-YYYY, DD.MM.YYYY, DD/MM/YYYY
    final datePatterns = [
      RegExp(r'\b(20\d{2})[-.\/](0[1-9]|1[0-2])[-.\/](0[1-9]|[12]\d|3[01])\b'), // YYYY-MM-DD
      RegExp(r'\b(0[1-9]|[12]\d|3[01])[-.\/](0[1-9]|1[0-2])[-.\/](20\d{2})\b'), // DD-MM-YYYY
      RegExp(r'\b(0[1-9]|[12]\d|3[01])[-.\/](0[1-9]|1[0-2])[-.\/](\d{2})\b'),     // DD-MM-YY
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(fullText);
      if (match != null) {
        try {
          int year, month, day;
          if (match.group(1)!.length == 4) {
            // YYYY-MM-DD
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else if (match.group(3)!.length == 4) {
            // DD-MM-YYYY
            day = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
          } else {
            // DD-MM-YY
            day = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            year = 2000 + int.parse(match.group(3)!);
          }

          final now = DateTime.now();
          if (year >= 2000 && year <= now.year + 1 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            final parsed = DateTime(year, month, day);
            // Ignore future dates beyond tomorrow
            if (parsed.isBefore(now.add(const Duration(days: 2)))) {
              return parsed;
            }
          }
        } catch (_) {}
      }
    }

    return null;
  }

  static String? _extractLocation(List<String> lines, String fullText) {
    final upper = fullText.toUpperCase();

    // 1. Check known fuel brands
    for (final brand in _fuelBrands) {
      if (upper.contains(brand)) {
        // Try to find the specific line for station number / details
        for (final line in lines.take(6)) {
          if (line.toUpperCase().contains(brand)) {
            return line;
          }
        }
        return brand;
      }
    }

    // 2. Check car service keywords
    for (final serviceKw in _serviceKeywords) {
      if (upper.contains(serviceKw)) {
        for (final line in lines.take(6)) {
          if (line.toUpperCase().contains(serviceKw)) {
            return line;
          }
        }
        return serviceKw;
      }
    }

    // 3. Fallback: inspect top 3 lines (merchant name is usually first 1-2 lines on receipt)
    for (final line in lines.take(3)) {
      final cleanLine = line.toUpperCase();
      // Skip generic receipt headers
      if (cleanLine.contains('PARAGON') ||
          cleanLine.contains('FISKALNY') ||
          cleanLine.contains('FAKTURA') ||
          cleanLine.contains('ORYGINAŁ') ||
          cleanLine.contains('KOPIA') ||
          cleanLine.length < 3) {
        continue;
      }
      return line;
    }

    return null;
  }

  static (ExpenseCategory, String?) _detectCategoryAndTitle(String fullText, String? location) {
    final upper = fullText.toUpperCase();

    // 1. Car wash check (prioritize car wash over general fuel if specific washing keywords exist)
    if (RegExp(r'(MYJNIA|PROGRAM\s*\d|MYCIE|PIANA|WOSK|SUSZENIE|ODKURZACZ)', caseSensitive: false).hasMatch(upper)) {
      return (ExpenseCategory.tollsFees, 'Myjnia samochodowa');
    }

    // 2. Fuel check
    final isFuelStation = _fuelBrands.any((brand) => upper.contains(brand));
    final hasFuelKeywords = RegExp(
      r'(PB\s*95|PB\s*98|PB95|PB98|\bON\b|DIESEL|LPG|AUTOGAZ|EFECTA|VERVA|ULTIMATE|V-POWER|MILES|LITR|LITRY|DYSTRYBUTOR|BENZYNA)',
      caseSensitive: false,
    ).hasMatch(upper);

    if (isFuelStation || hasFuelKeywords) {
      final title = location != null && location.isNotEmpty ? 'Tankowanie ($location)' : 'Tankowanie paliwa';
      return (ExpenseCategory.fuel, title);
    }

    // 3. Insurance check
    if (RegExp(r'(UBEZPIECZENIE|POLISA|OC\/AC|\bOC\b|\bAC\b|NNW|ASSISTANCE|PZU|WARTA|ERGO\s*HESTIA|ALLIANZ|GENERALI|UNIQA)', caseSensitive: false).hasMatch(upper)) {
      return (ExpenseCategory.insurance, 'Ubezpieczenie pojazdu');
    }

    // 4. Service / Maintenance check
    if (RegExp(r'(WYMIANA\s*OLEJU|ROZRZĄD|ROZRZAD|PRZEGLĄD|PRZEGLAD|DIAGNOSTYKA|SERWIS|KLIMATYZACJA|KLIMATYZACJI|NAPRAWA|ROBOCIZNA|USŁUGA|USLUGA|GEOMETRIA)', caseSensitive: false).hasMatch(upper)) {
      final title = location != null && location.isNotEmpty ? 'Serwis ($location)' : 'Serwis i naprawa';
      return (ExpenseCategory.service, title);
    }

    // 5. Parts check
    if (RegExp(r'(KLOCKI|TARCZE|FILTR|OLEJ|WYCIERACZKI|PŁYN|PLYN|AKUMULATOR|ŚWIECE|SWIECE|ŻARÓWKA|ZAROWKA|OPONY|CZĘŚCI|CZESCI|AMORTYZATOR)', caseSensitive: false).hasMatch(upper)) {
      return (ExpenseCategory.parts, 'Części i eksploatacja');
    }

    // Default
    final defaultTitle = location != null && location.isNotEmpty ? 'Wydatek ($location)' : 'Wydatek z paragonu';
    return (ExpenseCategory.tollsFees, defaultTitle);
  }
}

class ReceiptOcrService {
  final ImagePicker _picker;

  ReceiptOcrService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<ParsedReceiptData?> scanImageFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      return ReceiptParser.parse(recognizedText.text);
    } catch (e) {
      if (kDebugMode) {
        print('Error during OCR text recognition: $e');
      }
      return null;
    } finally {
      await textRecognizer.close();
    }
  }

  Future<ParsedReceiptData?> pickAndScan({required ImageSource source}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      if (!await file.exists()) return null;

      return await scanImageFile(pickedFile.path);
    } catch (e) {
      if (kDebugMode) {
        print('Error in pickAndScan: $e');
      }
      return null;
    }
  }
}
