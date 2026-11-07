import 'package:autolog/core/utils/formatters.dart';
import 'package:autolog/domain/models/service_reminder.dart';
import 'package:autolog/domain/models/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFormatters tests', () {
    test('currency formats PLN properly', () {
      expect(AppFormatters.currency(1234.56), contains('1'));
      expect(AppFormatters.currency(1234.56), contains('zł'));
      expect(AppFormatters.currency(0), contains('0,00'));
    });

    test('mileage formats km properly', () {
      expect(AppFormatters.mileage(185400), contains('km'));
      expect(AppFormatters.mileage(185400), contains('185'));
    });

    test('costPerKm formats properly', () {
      expect(AppFormatters.costPerKm(0.48), contains('0,48'));
      expect(AppFormatters.costPerKm(0.48), contains('zł/km'));
    });

    test('reminderStatusLabel handles date-based reminders correctly', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final reminderFuture = ServiceReminder(
        id: '1',
        vehicleId: 'v1',
        title: 'Przegląd',
        description: 'Coroczny przegląd',
        dueDate: AppFormatters.formatIsoDate(futureDate),
        daysRemaining: 10,
        severity: AlertSeverity.info,
        type: AlertType.technicalInspection,
      );

      final label = AppFormatters.reminderStatusLabel(reminderFuture);
      expect(label, 'Za 10 dni');
    });

    test('reminderStatusLabel handles mileage-based reminders correctly', () {
      final reminderKm = const ServiceReminder(
        id: '2',
        vehicleId: 'v1',
        title: 'Wymiana oleju',
        description: 'Wymiana oleju 5W30',
        dueMileageKm: 200000,
        kmRemaining: 5000,
        severity: AlertSeverity.warning,
        type: AlertType.oilService,
      );

      final label = AppFormatters.reminderStatusLabel(reminderKm);
      expect(label, contains('Za 5'));
      expect(label, contains('000 km'));
    });

    test('reminderStatusLabel handles overdue reminders', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final reminderPast = ServiceReminder(
        id: '3',
        vehicleId: 'v1',
        title: 'OC',
        description: 'Polisa OC',
        dueDate: AppFormatters.formatIsoDate(pastDate),
        daysRemaining: -5,
        severity: AlertSeverity.critical,
        type: AlertType.insurance,
      );

      final label = AppFormatters.reminderStatusLabel(reminderPast);
      expect(label, 'Przeterminowane (5 dni temu)');

      final reminderOverdueKm = const ServiceReminder(
        id: '4',
        vehicleId: 'v1',
        title: 'Wymiana oleju',
        description: 'Serwis',
        dueMileageKm: 160000,
        kmRemaining: -500,
        severity: AlertSeverity.critical,
        type: AlertType.oilService,
      );

      final labelKm = AppFormatters.reminderStatusLabel(reminderOverdueKm);
      expect(labelKm, contains('Przekroczono o'));
      expect(labelKm, contains('500 km'));
    });

    test('multi-currency formatting supports EUR and USD', () {
      expect(AppFormatters.currency(50.0, currencyCode: 'EUR'), contains('€'));
      expect(AppFormatters.currency(50.0, currencyCode: 'USD'), contains('\$'));
      expect(
        AppFormatters.shortCurrency(1200.0, currencyCode: 'USD'),
        contains('1,200'),
      );
      expect(
        AppFormatters.shortCurrency(1200.0, currencyCode: 'EUR'),
        contains('€'),
      );
    });

    test('distance unit formatting supports miles', () {
      expect(AppFormatters.mileage(12500, unit: 'mi'), contains('12'));
      expect(AppFormatters.mileage(12500, unit: 'mi'), contains('mi'));
      expect(
        AppFormatters.costPerDistance(0.35, currencyCode: 'USD', unit: 'mi'),
        contains('/mi'),
      );
    });
  });
}
