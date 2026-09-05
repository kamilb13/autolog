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

  /// Safe status label for reminder cards without "za null dni"
  static String reminderStatusLabel(ServiceReminder reminder) {
    switch (reminder.severity) {
      case AlertSeverity.critical:
        if (reminder.daysRemaining != null && reminder.daysRemaining! <= 0) {
          return 'Wygasło!';
        }
        if (reminder.daysRemaining != null) {
          return 'Za ${reminder.daysRemaining} dni';
        }
        if (reminder.kmRemaining != null) {
          return 'Za ${_mileageFormat.format(reminder.kmRemaining)} km';
        }
        return 'Pilne!';

      case AlertSeverity.warning:
        if (reminder.kmRemaining != null) {
          return 'Za ${_mileageFormat.format(reminder.kmRemaining)} km';
        }
        if (reminder.daysRemaining != null) {
          return 'Za ${reminder.daysRemaining} dni';
        }
        return 'Wkrótce';

      case AlertSeverity.info:
        if (reminder.daysRemaining != null) {
          return 'Za ${reminder.daysRemaining} dni';
        }
        if (reminder.kmRemaining != null) {
          return 'Za ${_mileageFormat.format(reminder.kmRemaining)} km';
        }
        return 'Zaplanowane';
    }
  }
}
