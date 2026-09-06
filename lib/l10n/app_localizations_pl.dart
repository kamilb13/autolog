// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'AutoLog';

  @override
  String get navGarage => 'Garaż';

  @override
  String get navExpenses => 'Wydatki';

  @override
  String get navReminders => 'Terminy';

  @override
  String get navStats => 'Statystyki';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonUndo => 'COFNIJ';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonEdit => 'Edytuj';

  @override
  String get commonAdd => 'Dodaj';

  @override
  String get commonRefresh => 'Odśwież';

  @override
  String get commonSearch => 'Szukaj...';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonDone => 'Gotowe';

  @override
  String get commonConfirm => 'Potwierdź';

  @override
  String get commonDetails => 'Szczegóły';

  @override
  String get commonError => 'Wystąpił błąd';

  @override
  String get commonRetry => 'Spróbuj ponownie';

  @override
  String get commonLoading => 'Wczytywanie...';

  @override
  String get commonCopied => 'Skopiowano do schowka';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsLanguageSection => 'Język aplikacji';

  @override
  String get settingsLanguageSystem => 'Domyślny systemowy';

  @override
  String get settingsLanguageSystemSubtitle =>
      'Automatyczne dopasowanie do telefonu';

  @override
  String get settingsLanguagePl => 'Polski (PL)';

  @override
  String get settingsLanguagePlSubtitle => 'Język polski';

  @override
  String get settingsLanguageEn => 'English (EN)';

  @override
  String get settingsLanguageEnSubtitle => 'Język angielski';

  @override
  String get settingsCurrencySection => 'Waluta';

  @override
  String get settingsCurrencyPln => 'Polski Złoty (PLN / zł)';

  @override
  String get settingsCurrencyEur => 'Euro (EUR / €)';

  @override
  String get settingsCurrencyUsd => 'Dolar amerykański (USD / \$)';

  @override
  String get settingsUnitSection => 'Jednostka odległości';

  @override
  String get settingsUnitKm => 'Kilometry (km)';

  @override
  String get settingsUnitMi => 'Mile (mi)';

  @override
  String get settingsThemeSection => 'Motyw graficzny';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsThemeSystemSubtitle => 'Dopasuj do motywu telefonu';

  @override
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeLightSubtitle => 'Jasny motyw interfejsu';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsThemeDarkSubtitle => 'Ciemny motyw (oszczędza baterię)';

  @override
  String get settingsBackupSection => 'Kopia zapasowa i dane';

  @override
  String get settingsBackupDialogBtn => 'Zarządzaj kopią zapasową (JSON)';

  @override
  String get settingsBackupSubtitle =>
      'Eksportuj lub importuj bazę danych w formacie JSON';

  @override
  String get settingsAboutSection => 'O aplikacji';

  @override
  String get settingsVersion => 'Wersja';

  @override
  String get settingsAppDesc =>
      'Lokalny, dziennik serwisowy i kosztów pojazdów.';

  @override
  String get garageTitle => 'Garaż';

  @override
  String get garageEmptyTitle => 'Twój garaż jest pusty';

  @override
  String get garageEmptySubtitle =>
      'Dodaj swój pierwszy samochód lub motocykl, aby rejestrować wydatki i terminy serwisowe.';

  @override
  String get garageAddFirstVehicle => 'Dodaj pierwszy pojazd';

  @override
  String get garageAddVehicle => 'Dodaj auto';

  @override
  String garageTotalVehicles(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pojazdu',
      many: '$count pojazdów',
      few: '$count pojazdy',
      one: '1 pojazd',
    );
    return '$_temp0';
  }

  @override
  String garageActiveAlerts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pilnych spraw',
      many: '$count pilnych spraw',
      few: '$count pilne sprawy',
      one: '1 pilna sprawa',
      zero: 'Brak pilnych spraw',
    );
    return '$_temp0';
  }

  @override
  String get garageBackupTooltip => 'Kopia zapasowa i przywracanie';

  @override
  String get garageQuickMileage => 'Szybka aktualizacja licznika';

  @override
  String get garageCurrentMileage => 'Aktualny przebieg';

  @override
  String get garageNewMileage => 'Nowy przebieg';

  @override
  String get dashboardTitle => 'Pulpit Pojazdu';

  @override
  String get dashboardMileageKpi => 'LICZNIK';

  @override
  String get dashboardExpensesKpi => 'WYDATKI';

  @override
  String get dashboardPurchaseKpi => 'ZAKUP';

  @override
  String get dashboardVinCopied => 'Skopiowano numer VIN';

  @override
  String get dashboardPlateCopied => 'Skopiowano numer rejestracyjny';

  @override
  String get dashboardNoVin => 'VIN: Brak (kliknij, aby dodać)';

  @override
  String get dashboardRemindersTitle => 'Alerty i Przypomnienia';

  @override
  String get dashboardTimelineTitle => 'Oś czasu wydatków';

  @override
  String get dashboardNewExpense => 'Nowy wydatek';

  @override
  String get dashboardSettingsTooltip => 'Ustawienia pojazdu';

  @override
  String get expensesTitle => 'Wydatki';

  @override
  String get expensesTotalKpi => 'ŁĄCZNIE WYDATKI';

  @override
  String get expensesCountKpi => 'LICZBA WPISÓW';

  @override
  String get expensesSearchPlaceholder =>
      'Szukaj wydatku (tytuł, notatka, warsztat)...';

  @override
  String get expensesFilterAllVehicles => 'Wszystkie auta';

  @override
  String get expensesFilterAllCategories => 'Wszystkie kategorie';

  @override
  String expensesDeletedMsg(Object title) {
    return 'Usunięto wpis \"$title\"';
  }

  @override
  String get expensesEmptyTitle => 'Brak zarejestrowanych wydatków';

  @override
  String get expensesEmptySubtitle =>
      'Kliknij przycisk poniżej, aby dodać tankowanie, serwis lub ubezpieczenie.';

  @override
  String get addExpenseTitle => 'Nowy wydatek';

  @override
  String get editExpenseTitle => 'Edytuj wydatek';

  @override
  String get addExpenseAmount => 'Kwota';

  @override
  String get addExpenseTitleLabel => 'Tytuł / Usługa';

  @override
  String get addExpenseTitleHint =>
      'np. Tankowanie, Wymiana oleju, Wycieraczki...';

  @override
  String get addExpenseCategory => 'Kategoria';

  @override
  String get addExpenseDate => 'Data';

  @override
  String get addExpenseMileage => 'Stan licznika';

  @override
  String get addExpenseWorkshop =>
      'Warsztat / Stacja / Lokalizacja (opcjonalnie)';

  @override
  String get addExpenseNote => 'Notatka / Uwagi (opcjonalnie)';

  @override
  String get addExpenseSuggestions => 'Popularne podpowiedzi';

  @override
  String get addExpenseSaveBtn => 'Zapisz wydatek';

  @override
  String get editExpenseSaveBtn => 'Zapisz zmiany';

  @override
  String get expenseUpdatedMsg => 'Zaktualizowano wydatek!';

  @override
  String get expenseSavedMsg => 'Zapisano wydatek!';

  @override
  String dashboardCostPerDistance(Object distance, Object unit) {
    return 'Koszt na $distance $unit';
  }

  @override
  String get dashboardCostExcludesPrice => 'Bez ceny zakupu';

  @override
  String get dashboardEditDistanceTitle => 'Kalkulator kosztu na dystans';

  @override
  String dashboardEditDistanceLabel(Object unit) {
    return 'Dystans ($unit)';
  }

  @override
  String get dashboardEditDistanceBtn => 'Zatwierdź';

  @override
  String get addExpenseInvalidAmount => 'Podaj poprawną kwotę większą od zera';

  @override
  String get addExpenseInvalidTitle => 'Podaj nazwę wydatku';

  @override
  String get addExpenseInvalidMileage => 'Podaj prawidłowy stan licznika';

  @override
  String get categoryFuel => 'Paliwo';

  @override
  String get categoryService => 'Serwis i Naprawy';

  @override
  String get categoryInsurance => 'Ubezpieczenie i Opłaty';

  @override
  String get categoryTolls => 'Myjnia i Kosmetyki';

  @override
  String get categoryParts => 'Części i Eksploatacja';

  @override
  String get categoryOther => 'Inne';

  @override
  String get remindersTitle => 'Terminy i Alerty';

  @override
  String get remindersTabUrgent => 'Krytyczne';

  @override
  String get remindersTabWarning => 'Ostrzeżenia';

  @override
  String get remindersTabUpcoming => 'Zaplanowane';

  @override
  String get remindersTabCompleted => 'Wykonane';

  @override
  String get remindersMarkDone => 'Oznacz jako wykonane';

  @override
  String get remindersAddBtn => 'Dodaj termin';

  @override
  String get remindersEmptyTitle => 'Wszystko na bieżąco!';

  @override
  String get remindersEmptySubtitle =>
      'Brak aktywnych terminów lub przypomnień serwisowych.';

  @override
  String remindersStatusOverdue(Object days) {
    return 'Przeterminowane ($days dni temu)';
  }

  @override
  String get remindersStatusToday => 'Termin dzisiaj!';

  @override
  String get remindersStatusTomorrow => 'Termin jutro!';

  @override
  String remindersStatusInDays(Object days) {
    return 'Za $days dni';
  }

  @override
  String remindersStatusMileageLeft(Object km) {
    return 'Zostało $km';
  }

  @override
  String remindersStatusMileageOver(Object km) {
    return 'Przekroczono o $km';
  }

  @override
  String get addReminderTitle => 'Nowe przypomnienie';

  @override
  String get addReminderTitleLabel => 'Nazwa przypomnienia';

  @override
  String get addReminderTitleHint =>
      'np. Przegląd techniczny, Ubezpieczenie OC, Wymiana rozrządu';

  @override
  String get addReminderDesc => 'Opis / Notatka';

  @override
  String get addReminderTypeDate => 'Według daty';

  @override
  String get addReminderTypeMileage => 'Według przebiegu';

  @override
  String get addReminderDueDate => 'Data docelowa';

  @override
  String get addReminderDueMileage => 'Przebieg docelowy';

  @override
  String get addReminderSeverity => 'Priorytet ważności';

  @override
  String get addReminderSeverityCritical => 'Krytyczny (Czerwony)';

  @override
  String get addReminderSeverityWarning => 'Ostrzeżenie (Żółty)';

  @override
  String get addReminderSeverityInfo => 'Informacja (Niebieski)';

  @override
  String get addReminderInterval => 'Powtarzaj cyklicznie';

  @override
  String get statsTitle => 'Statystyki & TCO';

  @override
  String get statsTotalCost => 'Całkowity koszt posiadania (TCO)';

  @override
  String statsCostPerDistance(Object unit) {
    return 'Koszt za 1 $unit';
  }

  @override
  String get statsBreakdownTitle => 'Podział kosztów według kategorii';

  @override
  String get statsBuyerReportBtn => 'Generuj Raport dla Kupującego (PDF)';

  @override
  String get statsNoData =>
      'Brak wystarczających danych do wygenerowania statystyk.';

  @override
  String get vehicleAddTitle => 'Dodaj pojazd';

  @override
  String get vehicleEditTitle => 'Ustawienia pojazdu';

  @override
  String get vehicleBrand => 'Marka';

  @override
  String get vehicleModel => 'Model';

  @override
  String get vehicleGeneration => 'Generacja / Wersja (opcjonalnie)';

  @override
  String get vehicleYear => 'Rok produkcji';

  @override
  String get vehiclePlate => 'Numer rejestracyjny';

  @override
  String get vehicleFuel => 'Rodzaj paliwa';

  @override
  String get vehicleVin => 'Numer VIN (opcjonalnie)';

  @override
  String get vehiclePurchasePrice => 'Cena zakupu pojazdu (opcjonalnie)';

  @override
  String get vehicleDeleteBtn => 'Usuń pojazd z garażu';

  @override
  String get vehicleDeleteConfirm =>
      'Czy na pewno chcesz usunąć ten pojazd oraz wszystkie powiązane z nim wydatki i przypomnienia? Tej operacji nie można cofnąć.';

  @override
  String get backupDialogTitle => 'Kopia Zapasowa';

  @override
  String get backupDialogSubtitle => 'Lokalny plik JSON';

  @override
  String get backupProcessing =>
      'Przetwarzanie operacji na pliku bazy danych...';

  @override
  String get backupExportBtn => 'Eksportuj kopię bazy';

  @override
  String get backupImportBtn => 'Importuj i przywróć bazę';

  @override
  String get backupExportSuccess => 'Wyeksportowano kopię zapasową';

  @override
  String backupImportSuccess(
    Object expenses,
    Object reminders,
    Object vehicles,
  ) {
    return 'Pomyślnie przywrócono dane z kopii ($vehicles aut, $expenses wydatków, $reminders przypomnień)';
  }

  @override
  String get backupLocalNotice =>
      'Twoje dane są zapisane lokalnie w telefonie. Przed odinstalowaniem aplikacji lub zmianą telefonu wyeksportuj plik JSON i zapisz go na dysku lub wyślij mailem.';

  @override
  String get quickMileageTitle => 'Aktualizuj przebieg';

  @override
  String quickMileageCurrent(Object mileage) {
    return 'Obecny stan: $mileage';
  }

  @override
  String get quickMileageNew => 'Nowy stan licznika';

  @override
  String get quickMileageInvalid => 'Wprowadź prawidłowy przebieg';

  @override
  String get vehicleDeleteTitle => 'Usuwanie pojazdu';

  @override
  String vehicleDeletePrompt(Object name, Object plate) {
    return 'Czy na pewno chcesz trwale usunąć pojazd $name ($plate)?';
  }

  @override
  String get vehicleDeleteWarning =>
      'Wszystkie zarejestrowane wydatki, historia serwisowa i alerty tego auta zostaną bezpowrotnie usunięte.';

  @override
  String get vehicleDeleteHoldInstruction =>
      'Naciśnij i przytrzymaj czerwony przycisk, aby zatwierdzić';

  @override
  String get vehicleDeleteHoldBtn => 'Przytrzymaj, aby usunąć';

  @override
  String vehicleDeleteHoldingBtn(Object seconds) {
    return 'Trzymaj jeszcze ${seconds}s...';
  }

  @override
  String vehicleDeletedMsg(Object name) {
    return 'Usunięto pojazd $name';
  }

  @override
  String get vehicleSavedMsg => 'Zapisano zmiany w pojeździe!';

  @override
  String vehicleAddedMsg(Object name) {
    return 'Dodano pojazd $name do garażu!';
  }

  @override
  String get reportTitle => 'Raport Pojazdu';

  @override
  String get reportSubtitle => 'Historia serwisowa i dokument sprzedaży';

  @override
  String reportRegisteredEntries(Object count) {
    return 'Zarejestrowane pozycje ($count)';
  }

  @override
  String reportEntriesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozycji w raporcie',
      many: '$count pozycji w raporcie',
      few: '$count pozycje w raporcie',
      one: '1 pozycja w raporcie',
    );
    return '$_temp0';
  }

  @override
  String get reportNoEntries => 'Brak wpisów dla tego pojazdu.';

  @override
  String get reportPrintPdf => 'Podgląd';

  @override
  String get reportSharePdf => 'Udostępnij';

  @override
  String get reportCopyText => 'Kopiuj tekst';

  @override
  String get reportShareText => 'Udostępnij tekst';

  @override
  String get reportCopiedMsg => 'Tekst raportu skopiowany do schowka!';

  @override
  String get fuelTypeGasoline => 'Benzyna';

  @override
  String get fuelTypeDiesel => 'Diesel';

  @override
  String get fuelTypeHybrid => 'Hybryda';

  @override
  String get fuelTypeLpg => 'LPG';

  @override
  String get fuelTypeElectric => 'Elektryczny';

  @override
  String get ocrScanReceipt => 'Zeskanuj paragon / fakturę';

  @override
  String get ocrScanReceiptTooltip => 'Zeskanuj paragon lub fakturę aparatem';

  @override
  String get ocrSourceCamera => 'Zrób zdjęcie aparatem';

  @override
  String get ocrSourceGallery => 'Wybierz z galerii';

  @override
  String get ocrScanning => 'Rozpoznawanie tekstu z paragonu...';

  @override
  String get ocrSuccessBanner =>
      'Odczytano dane z paragonu. Zweryfikuj i zatwierdź.';

  @override
  String get ocrNoDataFound =>
      'Nie udało się odczytać kwoty ani daty ze zdjęcia.';
}
