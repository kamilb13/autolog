import 'package:intl/intl.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/models/service_reminder.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pl_PL',
    symbol: 'zł',
    decimalDigits: 2,
    customPattern: '#,##0.00 \u00a4',
  );

  static final NumberFormat _shortCurrencyFormat = NumberFormat.currency(
    locale: 'pl_PL',
    symbol: 'zł',
    decimalDigits: 0,
    customPattern: '#,##0 \u00a4',
  );

  static final NumberFormat _mileageFormat = NumberFormat.decimalPattern('pl_PL');

  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String shortCurrency(double amount) {
    return _shortCurrencyFormat.format(amount);
  }

  static String mileage(int km) {
    return '${_mileageFormat.format(km)} km';
  }

  static String costPerKm(double cost) {
    return '${_currencyFormat.format(cost)}/km';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'pl_PL').format(date);
  }

  static String formatIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDisplayDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Brak daty';
    try {
      if (rawDate.contains('-')) {
        final parsed = DateTime.parse(rawDate);
        return DateFormat('dd.MM.yyyy').format(parsed);
      }
      return rawDate;
    } catch (_) {
      return rawDate;
    }
  }

  static DateTime? parseFlexibleDate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    try {
      if (trimmed.contains('-')) {
        return DateTime.parse(trimmed);
      }
      if (trimmed.contains('.')) {
        final parts = trimmed.split('.');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
      if (trimmed.contains('/')) {
        final parts = trimmed.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Safe status label for reminder cards with human friendly Polish phrasing
  static String reminderStatusLabel(ServiceReminder reminder) {
    if (reminder.daysRemaining != null) {
      final days = reminder.daysRemaining!;
      if (days < 0) {
        return 'Przeterminowane (${days.abs()} dni temu)';
      } else if (days == 0) {
        return 'Termin dzisiaj!';
      } else if (days == 1) {
        return 'Termin jutro!';
      } else {
        return 'Za $days dni';
      }
    }

    if (reminder.kmRemaining != null) {
      final km = reminder.kmRemaining!;
      if (km < 0) {
        return 'Przekroczono o ${mileage(km.abs())}';
      } else if (km == 0) {
        return 'Limit osiągnięty!';
      } else {
        return 'Za ${mileage(km)}';
      }
    }

    switch (reminder.severity) {
      case AlertSeverity.critical:
        return 'Pilne!';
      case AlertSeverity.warning:
        return 'Wkrótce';
      case AlertSeverity.info:
        return 'Zaplanowane';
    }
  }
}
