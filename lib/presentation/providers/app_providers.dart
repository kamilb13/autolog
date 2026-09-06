import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/services/google_drive_service.dart';
import '../../data/services/receipt_ocr_service.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/buyer_report.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/expense_suggestion.dart';
import '../../domain/models/service_reminder.dart';
import '../../domain/models/tco_stats.dart';
import '../../domain/models/vehicle.dart';

// --- Base Repository Providers --- //
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository();
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService.instance;
});

final receiptOcrServiceProvider = Provider<ReceiptOcrService>((ref) {
  return ReceiptOcrService();
});

// --- Vehicles Notifier & State --- //
class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    return ref.read(vehicleRepositoryProvider).getAllVehicles();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(vehicleRepositoryProvider).getAllVehicles());
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await ref.read(vehicleRepositoryProvider).addVehicle(vehicle);
    await refresh();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await ref.read(vehicleRepositoryProvider).updateVehicle(vehicle);
    await refresh();
  }

  Future<void> updateMileage(String vehicleId, int newMileage) async {
    await ref.read(vehicleRepositoryProvider).updateMileage(vehicleId, newMileage);
    await refresh();
    ref.read(remindersNotifierProvider.notifier).refresh();
    ref.read(statsNotifierProvider.notifier).refresh();
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await ref.read(vehicleRepositoryProvider).deleteVehicle(vehicleId);
    await refresh();
    ref.read(expensesNotifierProvider.notifier).refresh();
    ref.read(remindersNotifierProvider.notifier).refresh();
    ref.read(statsNotifierProvider.notifier).refresh();
  }
}

final vehiclesNotifierProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
  VehiclesNotifier.new,
);

// --- Expenses Notifier & State --- //
class ExpensesState {
  final List<Expense> expenses;
  final String? selectedVehicleId;
  final ExpenseCategory? selectedCategory;
  final String searchQuery;
  final bool isLoading;

  const ExpensesState({
    this.expenses = const [],
    this.selectedVehicleId,
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
  });

  double get totalSum => expenses.fold(0.0, (sum, e) => sum + e.amountPln);

  ExpensesState copyWith({
    List<Expense>? expenses,
    String? selectedVehicleId,
    bool clearVehicleId = false,
    ExpenseCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      selectedVehicleId: clearVehicleId ? null : (selectedVehicleId ?? this.selectedVehicleId),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final ExpenseRepository _repository;
  final Ref _ref;

  ExpensesNotifier(this._repository, this._ref) : super(const ExpensesState()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true);
    final results = await _repository.getExpenses(
      vehicleId: state.selectedVehicleId,
      category: state.selectedCategory,
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(expenses: results, isLoading: false);
  }

  Future<void> setVehicleFilter(String? vehicleId) async {
    if (vehicleId == null || state.selectedVehicleId == vehicleId) {
      state = state.copyWith(clearVehicleId: true);
    } else {
      state = state.copyWith(selectedVehicleId: vehicleId);
    }
    await loadExpenses();
  }

  Future<void> setCategoryFilter(ExpenseCategory? category) async {
    if (category == null || state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
    await loadExpenses();
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.addExpense(expense);
    await loadExpenses();
    _ref.read(vehiclesNotifierProvider.notifier).refresh();
    _ref.read(remindersNotifierProvider.notifier).refresh();
    _ref.read(statsNotifierProvider.notifier).refresh();
    _ref.invalidate(expenseSuggestionsProvider);
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    await loadExpenses();
    _ref.read(vehiclesNotifierProvider.notifier).refresh();
    _ref.read(remindersNotifierProvider.notifier).refresh();
    _ref.read(statsNotifierProvider.notifier).refresh();
    _ref.invalidate(expenseSuggestionsProvider);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _repository.deleteExpense(expenseId);
    await loadExpenses();
    _ref.read(statsNotifierProvider.notifier).refresh();
    _ref.read(vehiclesNotifierProvider.notifier).refresh();
    _ref.invalidate(expenseSuggestionsProvider);
  }

  Future<void> refresh() async {
    await loadExpenses();
    _ref.invalidate(expenseSuggestionsProvider);
  }
}

final expensesNotifierProvider = StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
  return ExpensesNotifier(ref.read(expenseRepositoryProvider), ref);
});

final expenseSuggestionsProvider = FutureProvider<List<ExpenseSuggestion>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getLearnedSuggestions();
});

// --- Reminders Notifier & State --- //
class RemindersState {
  final List<ServiceReminder> reminders;
  final String? selectedVehicleId;
  final AlertSeverity? selectedSeverity;
  final String searchQuery;
  final bool isLoading;

  const RemindersState({
    this.reminders = const [],
    this.selectedVehicleId,
    this.selectedSeverity,
    this.searchQuery = '',
    this.isLoading = false,
  });

  int get criticalCount => reminders.where((r) => r.severity == AlertSeverity.critical).length;
  int get warningCount => reminders.where((r) => r.severity == AlertSeverity.warning).length;
  int get urgentCount => criticalCount + warningCount;

  RemindersState copyWith({
    List<ServiceReminder>? reminders,
    String? selectedVehicleId,
    bool clearVehicleId = false,
    AlertSeverity? selectedSeverity,
    bool clearSeverity = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      selectedVehicleId: clearVehicleId ? null : (selectedVehicleId ?? this.selectedVehicleId),
      selectedSeverity: clearSeverity ? null : (selectedSeverity ?? this.selectedSeverity),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  final ReminderRepository _repository;
  final Ref _ref;

  RemindersNotifier(this._repository, this._ref) : super(const RemindersState()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true);
    final results = await _repository.getReminders(
      vehicleId: state.selectedVehicleId,
      severityFilter: state.selectedSeverity,
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(reminders: results, isLoading: false);
  }

  Future<void> setVehicleFilter(String? vehicleId) async {
    if (vehicleId == null || state.selectedVehicleId == vehicleId) {
      state = state.copyWith(clearVehicleId: true);
    } else {
      state = state.copyWith(selectedVehicleId: vehicleId);
    }
    await loadReminders();
  }

  Future<void> setSeverityFilter(AlertSeverity? severity) async {
    if (severity == null || state.selectedSeverity == severity) {
      state = state.copyWith(clearSeverity: true);
    } else {
      state = state.copyWith(selectedSeverity: severity);
    }
    await loadReminders();
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadReminders();
  }

  Future<void> addReminder(ServiceReminder reminder) async {
    await _repository.addReminder(reminder);
    await loadReminders();
    _ref.read(vehiclesNotifierProvider.notifier).refresh();
  }

  Future<void> markCompleted(String reminderId) async {
    await _repository.markCompleted(reminderId);
    await loadReminders();
    _ref.read(vehiclesNotifierProvider.notifier).refresh();
  }

  Future<void> deleteReminder(String reminderId) async {
    await _repository.deleteReminder(reminderId);
    await loadReminders();
    _ref.read(vehiclesNotifierProvider.notifier).refresh();
  }

  Future<void> refresh() async {
    await loadReminders();
  }
}

final remindersNotifierProvider = StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier(ref.read(reminderRepositoryProvider), ref);
});

// --- Stats Notifier & State --- //
class StatsState {
  final String? selectedVehicleId;
  final TcoStats stats;
  final BuyerReport? buyerReport;
  final bool isLoading;
  final bool isGeneratingReport;

  const StatsState({
    this.selectedVehicleId,
    this.stats = TcoStats.empty,
    this.buyerReport,
    this.isLoading = false,
    this.isGeneratingReport = false,
  });

  StatsState copyWith({
    String? selectedVehicleId,
    bool clearVehicleId = false,
    TcoStats? stats,
    BuyerReport? buyerReport,
    bool clearBuyerReport = false,
    bool? isLoading,
    bool? isGeneratingReport,
  }) {
    return StatsState(
      selectedVehicleId: clearVehicleId ? null : (selectedVehicleId ?? this.selectedVehicleId),
      stats: stats ?? this.stats,
      buyerReport: clearBuyerReport ? null : (buyerReport ?? this.buyerReport),
      isLoading: isLoading ?? this.isLoading,
      isGeneratingReport: isGeneratingReport ?? this.isGeneratingReport,
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  final StatsRepository _repository;

  StatsNotifier(this._repository) : super(const StatsState()) {
    loadStats();
  }

  Future<void> loadStats([String? vehicleId]) async {
    state = state.copyWith(
      isLoading: true,
      selectedVehicleId: vehicleId,
      clearVehicleId: vehicleId == null,
    );
    final stats = await _repository.getTcoStats(vehicleId);
    state = state.copyWith(stats: stats, isLoading: false);
  }

  Future<void> selectVehicle(String? vehicleId) async {
    if (state.selectedVehicleId == vehicleId) {
      await loadStats(null);
    } else {
      await loadStats(vehicleId);
    }
  }

  Future<void> generateBuyerReport(String vehicleId) async {
    state = state.copyWith(isGeneratingReport: true);
    final report = await _repository.getBuyerReport(vehicleId);
    state = state.copyWith(buyerReport: report, isGeneratingReport: false);
  }

  void dismissBuyerReport() {
    state = state.copyWith(clearBuyerReport: true);
  }

  Future<void> refresh() async {
    await loadStats(state.selectedVehicleId);
  }
}

final statsNotifierProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref.read(statsRepositoryProvider));
});

// --- Google Drive Sync State & Notifier --- //
class DriveSyncState {
  final GoogleSignInAccount? user;
  final bool isSyncing;
  final String? statusMessage;
  final DateTime? lastBackupDate;

  const DriveSyncState({
    this.user,
    this.isSyncing = false,
    this.statusMessage,
    this.lastBackupDate,
  });

  bool get isSignedIn => user != null;

  DriveSyncState copyWith({
    GoogleSignInAccount? user,
    bool clearUser = false,
    bool? isSyncing,
    String? statusMessage,
    DateTime? lastBackupDate,
  }) {
    return DriveSyncState(
      user: clearUser ? null : (user ?? this.user),
      isSyncing: isSyncing ?? this.isSyncing,
      statusMessage: statusMessage ?? this.statusMessage,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }
}

class DriveSyncNotifier extends StateNotifier<DriveSyncState> {
  final GoogleDriveService _driveService;
  final Ref _ref;

  DriveSyncNotifier(this._driveService, this._ref) : super(const DriveSyncState()) {
    initAuth();
  }

  Future<void> initAuth() async {
    final account = await _driveService.signInSilently();
    if (account != null) {
      state = state.copyWith(user: account);
    }
  }

  Future<void> signIn() async {
    state = state.copyWith(isSyncing: true, statusMessage: 'Logowanie do Google...');
    final account = await _driveService.signIn();
    state = state.copyWith(user: account, isSyncing: false, statusMessage: account != null ? 'Zalogowano: ${account.email}' : 'Anulowano logowanie');
  }

  Future<void> signOut() async {
    await _driveService.signOut();
    state = state.copyWith(clearUser: true, statusMessage: 'Wylogowano');
  }

  Future<GoogleDriveSyncResult> backup() async {
    state = state.copyWith(isSyncing: true, statusMessage: 'Zapisywanie kopii zapasowej...');
    final result = await _driveService.backupToDrive();
    state = state.copyWith(
      isSyncing: false,
      statusMessage: result.message,
      lastBackupDate: result.backupDate ?? state.lastBackupDate,
      user: _driveService.currentUser,
    );
    return result;
  }

  Future<GoogleDriveSyncResult> restore() async {
    state = state.copyWith(isSyncing: true, statusMessage: 'Pobieranie kopii zapasowej...');
    final result = await _driveService.restoreFromDrive();
    state = state.copyWith(
      isSyncing: false,
      statusMessage: result.message,
      user: _driveService.currentUser,
    );
    if (result.isSuccess) {
      // Reload all data in providers
      _ref.read(vehiclesNotifierProvider.notifier).refresh();
      _ref.read(expensesNotifierProvider.notifier).refresh();
      _ref.read(remindersNotifierProvider.notifier).refresh();
      _ref.read(statsNotifierProvider.notifier).refresh();
    }
    return result;
  }

  Future<void> shareLocalBackup() async {
    await _driveService.exportAndShareLocalBackup();
  }

  Future<GoogleDriveSyncResult> importLocalBackup() async {
    state = state.copyWith(isSyncing: true, statusMessage: 'Wczytywanie pliku kopii zapasowej...');
    final result = await _driveService.importLocalBackupFromFile();
    state = state.copyWith(
      isSyncing: false,
      statusMessage: result.message,
    );
    if (result.isSuccess) {
      // Reload all data in providers
      _ref.read(vehiclesNotifierProvider.notifier).refresh();
      _ref.read(expensesNotifierProvider.notifier).refresh();
      _ref.read(remindersNotifierProvider.notifier).refresh();
      _ref.read(statsNotifierProvider.notifier).refresh();
      _ref.invalidate(expenseSuggestionsProvider);
    }
    return result;
  }
}

final driveSyncNotifierProvider = StateNotifierProvider<DriveSyncNotifier, DriveSyncState>((ref) {
  return DriveSyncNotifier(ref.read(googleDriveServiceProvider), ref);
});

// --- App Settings Notifier & Provider --- //
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.loadSettings();
    state = s;
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await _repo.saveSettings(state);
  }

  Future<void> setCurrency(AppCurrency currency) async {
    state = state.copyWith(currency: currency);
    await _repo.saveSettings(state);
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    state = state.copyWith(distanceUnit: unit);
    await _repo.saveSettings(state);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.saveSettings(state);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});

