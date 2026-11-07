import 'package:flutter_test/flutter_test.dart';
import 'package:autolog/data/services/receipt_ocr_service.dart';
import 'package:autolog/domain/models/expense.dart';

void main() {
  group('ReceiptParser Tests', () {
    test('parses PKN Orlen fuel receipt correctly', () {
      const orlenReceipt = '''
PKN ORLEN S.A.
STACJA PALIW NR 4321
30-001 KRAKOW, UL. MLYNSKA 10
NIP: 774-00-01-454
2026-05-14 14:35 NR: 004921
PARAGON FISKALNY
1. EFECTA DIESEL ON
   45.50 L * 6.69 PLN      304.40 A
--------------------------------------
SP. OPOD. A: 23.00%        247.48
KWOTA PTU A:                56.92
--------------------------------------
SUMA PLN                  304.40
ROZLICZENIE PŁATNOŚCI:
KARTA                     304.40
Nr transakcji: 9812401
DZIĘKUJEMY ZA ZAKUPY!
''';

      final parsed = ReceiptParser.parse(orlenReceipt);

      expect(parsed.amount, equals(304.40));
      expect(parsed.date, equals(DateTime(2026, 5, 14)));
      expect(parsed.location, contains('ORLEN'));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.fuel));
      expect(parsed.suggestedTitle, contains('Tankowanie'));
    });

    test(
      'parses Shell receipt with dot date format and European price syntax',
      () {
        const shellReceipt = '''
SHELL POLSKA SP. Z O.O.
STACJA 1024 WARSZAWA
NIP 526-030-91-24
PARAGON FISKALNY
DATA: 12.08.2026 GODZ. 18:20
1 V-POWER 95   30.00 L * 7.15    214.50 A
DO ZAPŁATY                 214.50 PLN
ZAPŁACONO KARTĄ:           214.50
''';

        final parsed = ReceiptParser.parse(shellReceipt);

        expect(parsed.amount, equals(214.50));
        expect(parsed.date, equals(DateTime(2026, 8, 12)));
        expect(parsed.location, contains('SHELL'));
        expect(parsed.suggestedCategory, equals(ExpenseCategory.fuel));
      },
    );

    test('parses Car Service & Repair workshop invoice/receipt', () {
      const workshopReceipt = '''
AUTO SERWIS KOWALSKI
MECHANIKA POJAZDOWA I WULKANIZACJA
UL. PROSTA 5, WROCŁAW
NIP: 894-123-45-67
DATA SPRZEDAŻY: 2026-03-20
1. WYMIANA OLEJU I FILTRÓW       150.00 A
2. OLEJ MOTUL 5W30 5L            220.00 A
3. KLOCKI HAMULCOWE PRZÓD        340.00 A
4. WYMIANA KLOCKÓW               180.00 A
-----------------------------------------
RAZEM PLN                        890.00
Zapłacono gotówką: 890.00 PLN
''';

      final parsed = ReceiptParser.parse(workshopReceipt);

      expect(parsed.amount, equals(890.00));
      expect(parsed.date, equals(DateTime(2026, 3, 20)));
      expect(parsed.location, contains('AUTO SERWIS'));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.service));
      expect(parsed.suggestedTitle, contains('Serwis'));
    });

    test('parses Car Wash receipt', () {
      const carWashReceipt = '''
MYJNIA BEZDOTYKOWA SPEED WASH
KRAKÓW, UL. WIELICKA
PARAGON FISKALNY
15-06-2026 11:05
PROGRAM MYCIA PREMIUM: 35,00 PLN
SUMA: 35,00 PLN
''';

      final parsed = ReceiptParser.parse(carWashReceipt);

      expect(parsed.amount, equals(35.00));
      expect(parsed.date, equals(DateTime(2026, 6, 15)));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.tollsFees));
      expect(parsed.suggestedTitle, equals('Myjnia samochodowa'));
    });

    test('parses Auto Parts shop receipt', () {
      const partsReceipt = '''
INTER CARS S.A.
FILIA KATOWICE
DATA: 05.07.2026
1. WYCIERACZKI BOSCH AEROTWIN    120.00
2. PŁYN DO SPRYSKIWACZY 5L        25.00
---------------------------------------
WARTOŚĆ BRUTTO:                  145.00
PŁATNOŚĆ KARTĄ:                  145.00
''';

      final parsed = ReceiptParser.parse(partsReceipt);

      expect(parsed.amount, equals(145.00));
      expect(parsed.date, equals(DateTime(2026, 7, 5)));
      expect(parsed.location, contains('INTER CARS'));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.parts));
    });

    test('handles empty or unrecognized receipt gracefully', () {
      final parsed = ReceiptParser.parse('');
      expect(parsed.amount, isNull);
      expect(parsed.date, isNull);
      expect(parsed.hasAnyData, isFalse);
    });
  });
}
