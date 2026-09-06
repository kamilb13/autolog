// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AutoLog';

  @override
  String get navGarage => 'Garage';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonUndo => 'UNDO';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonSearch => 'Search...';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDone => 'Done';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDetails => 'Details';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonCopied => 'Copied to clipboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'App Language';

  @override
  String get settingsLanguageSystem => 'System Default';

  @override
  String get settingsLanguageSystemSubtitle => 'Match device system language';

  @override
  String get settingsLanguagePl => 'Polish (PL)';

  @override
  String get settingsLanguagePlSubtitle => 'Polish language';

  @override
  String get settingsLanguageEn => 'English (EN)';

  @override
  String get settingsLanguageEnSubtitle => 'English language';

  @override
  String get settingsCurrencySection => 'Currency';

  @override
  String get settingsCurrencyPln => 'Polish Zloty (PLN / zł)';

  @override
  String get settingsCurrencyEur => 'Euro (EUR / €)';

  @override
  String get settingsCurrencyUsd => 'US Dollar (USD / \$)';

  @override
  String get settingsUnitSection => 'Distance Unit';

  @override
  String get settingsUnitKm => 'Kilometers (km)';

  @override
  String get settingsUnitMi => 'Miles (mi)';

  @override
  String get settingsThemeSection => 'Visual Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeSystemSubtitle => 'Follow device system theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeLightSubtitle => 'Light interface theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeDarkSubtitle => 'Dark theme (battery saving)';

  @override
  String get settingsBackupSection => 'Backup & Data';

  @override
  String get settingsBackupDialogBtn => 'Manage Backup (JSON)';

  @override
  String get settingsBackupSubtitle => 'Export or import database as JSON file';

  @override
  String get settingsAboutSection => 'About App';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsAppDesc =>
      '100% offline, privacy-first vehicle logbook and cost tracker.';

  @override
  String get garageTitle => 'Garage';

  @override
  String get garageEmptyTitle => 'Your garage is empty';

  @override
  String get garageEmptySubtitle =>
      'Add your first car or motorcycle to track expenses and service schedules.';

  @override
  String get garageAddFirstVehicle => 'Add first vehicle';

  @override
  String get garageAddVehicle => 'Add vehicle';

  @override
  String garageTotalVehicles(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '1 vehicle',
    );
    return '$_temp0';
  }

  @override
  String garageActiveAlerts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending alerts',
      one: '1 pending alert',
      zero: 'No pending alerts',
    );
    return '$_temp0';
  }

  @override
  String get garageBackupTooltip => 'Backup & Restore';

  @override
  String get garageQuickMileage => 'Quick Mileage Update';

  @override
  String get garageCurrentMileage => 'Current mileage';

  @override
  String get garageNewMileage => 'New mileage';

  @override
  String get dashboardTitle => 'Vehicle Dashboard';

  @override
  String get dashboardMileageKpi => 'ODOMETER';

  @override
  String get dashboardExpensesKpi => 'EXPENSES';

  @override
  String get dashboardPurchaseKpi => 'PURCHASE';

  @override
  String get dashboardVinCopied => 'VIN copied to clipboard';

  @override
  String get dashboardPlateCopied => 'License plate copied to clipboard';

  @override
  String get dashboardNoVin => 'VIN: None (tap to add)';

  @override
  String get dashboardRemindersTitle => 'Alerts & Reminders';

  @override
  String get dashboardTimelineTitle => 'Expense Timeline';

  @override
  String get dashboardNewExpense => 'New expense';

  @override
  String get dashboardSettingsTooltip => 'Vehicle settings';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesTotalKpi => 'TOTAL EXPENSES';

  @override
  String get expensesCountKpi => 'TOTAL ENTRIES';

  @override
  String get expensesSearchPlaceholder =>
      'Search expense (title, note, shop)...';

  @override
  String get expensesFilterAllVehicles => 'All vehicles';

  @override
  String get expensesFilterAllCategories => 'All categories';

  @override
  String expensesDeletedMsg(Object title) {
    return 'Deleted entry \"$title\"';
  }

  @override
  String get expensesEmptyTitle => 'No recorded expenses';

  @override
  String get expensesEmptySubtitle =>
      'Tap the button below to add fuel, service or insurance records.';

  @override
  String get addExpenseTitle => 'New Expense';

  @override
  String get editExpenseTitle => 'Edit Expense';

  @override
  String get addExpenseAmount => 'Amount';

  @override
  String get addExpenseTitleLabel => 'Title / Service';

  @override
  String get addExpenseTitleHint => 'e.g. Refuel, Oil change, Wipers...';

  @override
  String get addExpenseCategory => 'Category';

  @override
  String get addExpenseDate => 'Date';

  @override
  String get addExpenseMileage => 'Odometer reading';

  @override
  String get addExpenseWorkshop => 'Workshop / Station / Location (optional)';

  @override
  String get addExpenseNote => 'Note / Details (optional)';

  @override
  String get addExpenseSuggestions => 'Popular suggestions';

  @override
  String get addExpenseSaveBtn => 'Save Expense';

  @override
  String get addExpenseInvalidAmount =>
      'Please enter a valid amount greater than zero';

  @override
  String get addExpenseInvalidTitle => 'Please enter an expense title';

  @override
  String get addExpenseInvalidMileage =>
      'Please enter a valid odometer reading';

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryService => 'Service & Maintenance';

  @override
  String get categoryInsurance => 'Insurance & Fees';

  @override
  String get categoryTolls => 'Car Wash & Care';

  @override
  String get categoryParts => 'Parts & Consumables';

  @override
  String get categoryOther => 'Other';

  @override
  String get remindersTitle => 'Deadlines & Alerts';

  @override
  String get remindersTabUrgent => 'Critical';

  @override
  String get remindersTabWarning => 'Warnings';

  @override
  String get remindersTabUpcoming => 'Upcoming';

  @override
  String get remindersTabCompleted => 'Completed';

  @override
  String get remindersMarkDone => 'Mark as done';

  @override
  String get remindersAddBtn => 'Add reminder';

  @override
  String get remindersEmptyTitle => 'All caught up!';

  @override
  String get remindersEmptySubtitle =>
      'No active reminders or pending maintenance.';

  @override
  String remindersStatusOverdue(Object days) {
    return 'Overdue ($days days ago)';
  }

  @override
  String get remindersStatusToday => 'Due today!';

  @override
  String get remindersStatusTomorrow => 'Due tomorrow!';

  @override
  String remindersStatusInDays(Object days) {
    return 'In $days days';
  }

  @override
  String remindersStatusMileageLeft(Object km) {
    return '$km remaining';
  }

  @override
  String remindersStatusMileageOver(Object km) {
    return 'Exceeded by $km';
  }

  @override
  String get addReminderTitle => 'New Reminder';

  @override
  String get addReminderTitleLabel => 'Reminder title';

  @override
  String get addReminderTitleHint =>
      'e.g. Inspection, Insurance renewal, Timing belt';

  @override
  String get addReminderDesc => 'Description / Note';

  @override
  String get addReminderTypeDate => 'By Date';

  @override
  String get addReminderTypeMileage => 'By Mileage';

  @override
  String get addReminderDueDate => 'Due Date';

  @override
  String get addReminderDueMileage => 'Due Mileage';

  @override
  String get addReminderSeverity => 'Severity';

  @override
  String get addReminderSeverityCritical => 'Critical (Red)';

  @override
  String get addReminderSeverityWarning => 'Warning (Yellow)';

  @override
  String get addReminderSeverityInfo => 'Info (Blue)';

  @override
  String get addReminderInterval => 'Repeat recurring';

  @override
  String get statsTitle => 'Stats & TCO';

  @override
  String get statsTotalCost => 'Total Cost of Ownership (TCO)';

  @override
  String statsCostPerDistance(Object unit) {
    return 'Cost per 1 $unit';
  }

  @override
  String get statsBreakdownTitle => 'Cost breakdown by category';

  @override
  String get statsBuyerReportBtn => 'Generate Buyer Report (PDF)';

  @override
  String get statsNoData => 'Not enough data to calculate statistics.';

  @override
  String get vehicleAddTitle => 'Add Vehicle';

  @override
  String get vehicleEditTitle => 'Vehicle Settings';

  @override
  String get vehicleBrand => 'Brand';

  @override
  String get vehicleModel => 'Model';

  @override
  String get vehicleGeneration => 'Generation / Trim (optional)';

  @override
  String get vehicleYear => 'Manufacturing Year';

  @override
  String get vehiclePlate => 'License Plate';

  @override
  String get vehicleFuel => 'Fuel Type';

  @override
  String get vehicleVin => 'VIN Number (optional)';

  @override
  String get vehiclePurchasePrice => 'Vehicle Purchase Price (optional)';

  @override
  String get vehicleDeleteBtn => 'Remove vehicle from garage';

  @override
  String get vehicleDeleteConfirm =>
      'Are you sure you want to delete this vehicle and all related expenses and reminders? This action cannot be undone.';

  @override
  String get backupDialogTitle => 'Data Backup';

  @override
  String get backupDialogSubtitle => 'Local JSON file';

  @override
  String get backupProcessing => 'Processing database file operation...';

  @override
  String get backupExportBtn => 'Export database backup';

  @override
  String get backupImportBtn => 'Import and restore backup';

  @override
  String get backupExportSuccess => 'Backup exported successfully';

  @override
  String backupImportSuccess(
    Object expenses,
    Object reminders,
    Object vehicles,
  ) {
    return 'Successfully restored data from backup ($vehicles cars, $expenses expenses, $reminders reminders)';
  }

  @override
  String get backupLocalNotice =>
      'Your data is stored locally on your device. Before uninstalling the app or switching phones, export a JSON backup and save it to cloud storage or send it via email.';

  @override
  String get quickMileageTitle => 'Update Mileage';

  @override
  String quickMileageCurrent(Object mileage) {
    return 'Current odometer: $mileage';
  }

  @override
  String get quickMileageNew => 'New odometer reading';

  @override
  String get quickMileageInvalid => 'Please enter a valid mileage';

  @override
  String get vehicleDeleteTitle => 'Delete Vehicle';

  @override
  String vehicleDeletePrompt(Object name, Object plate) {
    return 'Are you sure you want to permanently delete $name ($plate)?';
  }

  @override
  String get vehicleDeleteWarning =>
      'All recorded expenses, service history, and alerts for this vehicle will be permanently removed.';

  @override
  String get vehicleDeleteHoldInstruction =>
      'Press and hold the red button to confirm deletion';

  @override
  String get vehicleDeleteHoldBtn => 'Hold to delete';

  @override
  String vehicleDeleteHoldingBtn(Object seconds) {
    return 'Hold for ${seconds}s...';
  }

  @override
  String vehicleDeletedMsg(Object name) {
    return 'Deleted vehicle $name';
  }

  @override
  String get vehicleSavedMsg => 'Vehicle changes saved!';

  @override
  String vehicleAddedMsg(Object name) {
    return 'Added $name to garage!';
  }

  @override
  String get reportTitle => 'Vehicle Report';

  @override
  String get reportSubtitle => 'Service history and sales document';

  @override
  String reportRegisteredEntries(Object count) {
    return 'Recorded entries ($count)';
  }

  @override
  String reportEntriesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries in report',
      one: '1 entry in report',
    );
    return '$_temp0';
  }

  @override
  String get reportNoEntries => 'No entries for this vehicle.';

  @override
  String get reportPrintPdf => 'Preview';

  @override
  String get reportSharePdf => 'Share';

  @override
  String get reportCopyText => 'Copy text';

  @override
  String get reportShareText => 'Share text';

  @override
  String get reportCopiedMsg => 'Report text copied to clipboard!';

  @override
  String get fuelTypeGasoline => 'Gasoline';

  @override
  String get fuelTypeDiesel => 'Diesel';

  @override
  String get fuelTypeHybrid => 'Hybrid';

  @override
  String get fuelTypeLpg => 'LPG';

  @override
  String get fuelTypeElectric => 'Electric';

  @override
  String get ocrScanReceipt => 'Scan receipt / invoice';

  @override
  String get ocrScanReceiptTooltip => 'Scan receipt or invoice using camera';

  @override
  String get ocrSourceCamera => 'Take photo with camera';

  @override
  String get ocrSourceGallery => 'Choose from gallery';

  @override
  String get ocrScanning => 'Recognizing receipt text...';

  @override
  String get ocrSuccessBanner =>
      'Extracted receipt data. Please verify and confirm.';

  @override
  String get ocrNoDataFound =>
      'Could not detect amount or date from this image.';
}
