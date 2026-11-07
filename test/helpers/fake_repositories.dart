import 'package:autolog/data/repositories/expense_repository.dart';
import 'package:autolog/data/repositories/reminder_repository.dart';
import 'package:autolog/data/repositories/settings_repository.dart';
import 'package:autolog/data/repositories/stats_repository.dart';
import 'package:autolog/data/repositories/vehicle_repository.dart';
import 'package:autolog/domain/models/app_settings.dart';
import 'package:autolog/domain/models/expense.dart';
import 'package:autolog/domain/models/expense_suggestion.dart';
import 'package:autolog/domain/models/service_reminder.dart';
import 'package:autolog/domain/models/vehicle.dart';
import 'package:autolog/presentation/providers/app_providers.dart';

final testRepositoryOverrides = [
  vehicleRepositoryProvider.overrideWith((ref) => _Vehicles()),
  expenseRepositoryProvider.overrideWith((ref) => _Expenses()),
  reminderRepositoryProvider.overrideWith((ref) => _Reminders()),
  settingsRepositoryProvider.overrideWith((ref) => _Settings()),
  statsRepositoryProvider.overrideWith(
    (ref) => StatsRepository(
      expenseRepository: ref.read(expenseRepositoryProvider),
      vehicleRepository: ref.read(vehicleRepositoryProvider),
    ),
  ),
];

class _Vehicles extends VehicleRepository {
  @override
  Future<List<Vehicle>> getAllVehicles() async => [];
}

class _Expenses extends ExpenseRepository {
  @override
  Future<List<Expense>> getExpenses({
    String? vehicleId,
    ExpenseCategory? category,
    String? searchQuery,
  }) async => [];

  @override
  Future<List<ExpenseSuggestion>> getLearnedSuggestions() async => [];
}

class _Reminders extends ReminderRepository {
  @override
  Future<List<ServiceReminder>> getReminders({
    String? vehicleId,
    AlertSeverity? severityFilter,
    String? searchQuery,
  }) async => [];
}

class _Settings extends SettingsRepository {
  @override
  Future<AppSettings> loadSettings() async => const AppSettings();

  @override
  Future<void> saveSettings(AppSettings settings) async {}
}
