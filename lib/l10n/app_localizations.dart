import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'AutoLog'**
  String get appTitle;

  /// No description provided for @navGarage.
  ///
  /// In pl, this message translates to:
  /// **'Garaż'**
  String get navGarage;

  /// No description provided for @navExpenses.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki'**
  String get navExpenses;

  /// No description provided for @navReminders.
  ///
  /// In pl, this message translates to:
  /// **'Terminy'**
  String get navReminders;

  /// No description provided for @navStats.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get navSettings;

  /// No description provided for @commonSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get commonCancel;

  /// No description provided for @commonUndo.
  ///
  /// In pl, this message translates to:
  /// **'COFNIJ'**
  String get commonUndo;

  /// No description provided for @commonDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get commonAdd;

  /// No description provided for @commonRefresh.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież'**
  String get commonRefresh;

  /// No description provided for @commonSearch.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj...'**
  String get commonSearch;

  /// No description provided for @commonClose.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get commonClose;

  /// No description provided for @commonDone.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get commonDone;

  /// No description provided for @commonConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź'**
  String get commonConfirm;

  /// No description provided for @commonDetails.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły'**
  String get commonDetails;

  /// No description provided for @commonError.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił błąd'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie...'**
  String get commonLoading;

  /// No description provided for @commonCopied.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano do schowka'**
  String get commonCopied;

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In pl, this message translates to:
  /// **'Język aplikacji'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In pl, this message translates to:
  /// **'Domyślny systemowy'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSystemSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Automatyczne dopasowanie do telefonu'**
  String get settingsLanguageSystemSubtitle;

  /// No description provided for @settingsLanguagePl.
  ///
  /// In pl, this message translates to:
  /// **'Polski (PL)'**
  String get settingsLanguagePl;

  /// No description provided for @settingsLanguagePlSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Język polski'**
  String get settingsLanguagePlSubtitle;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In pl, this message translates to:
  /// **'English (EN)'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageEnSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Język angielski'**
  String get settingsLanguageEnSubtitle;

  /// No description provided for @settingsCurrencySection.
  ///
  /// In pl, this message translates to:
  /// **'Waluta'**
  String get settingsCurrencySection;

  /// No description provided for @settingsCurrencyPln.
  ///
  /// In pl, this message translates to:
  /// **'Polski Złoty (PLN / zł)'**
  String get settingsCurrencyPln;

  /// No description provided for @settingsCurrencyEur.
  ///
  /// In pl, this message translates to:
  /// **'Euro (EUR / €)'**
  String get settingsCurrencyEur;

  /// No description provided for @settingsCurrencyUsd.
  ///
  /// In pl, this message translates to:
  /// **'Dolar amerykański (USD / \$)'**
  String get settingsCurrencyUsd;

  /// No description provided for @settingsUnitSection.
  ///
  /// In pl, this message translates to:
  /// **'Jednostka odległości'**
  String get settingsUnitSection;

  /// No description provided for @settingsUnitKm.
  ///
  /// In pl, this message translates to:
  /// **'Kilometry (km)'**
  String get settingsUnitKm;

  /// No description provided for @settingsUnitMi.
  ///
  /// In pl, this message translates to:
  /// **'Mile (mi)'**
  String get settingsUnitMi;

  /// No description provided for @settingsThemeSection.
  ///
  /// In pl, this message translates to:
  /// **'Motyw graficzny'**
  String get settingsThemeSection;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In pl, this message translates to:
  /// **'Systemowy'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeSystemSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dopasuj do motywu telefonu'**
  String get settingsThemeSystemSubtitle;

  /// No description provided for @settingsThemeLight.
  ///
  /// In pl, this message translates to:
  /// **'Jasny'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeLightSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Jasny motyw interfejsu'**
  String get settingsThemeLightSubtitle;

  /// No description provided for @settingsThemeDark.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeDarkSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny motyw (oszczędza baterię)'**
  String get settingsThemeDarkSubtitle;

  /// No description provided for @settingsBackupSection.
  ///
  /// In pl, this message translates to:
  /// **'Kopia zapasowa i dane'**
  String get settingsBackupSection;

  /// No description provided for @settingsBackupDialogBtn.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzaj kopią zapasową (JSON)'**
  String get settingsBackupDialogBtn;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Eksportuj lub importuj bazę danych w formacie JSON'**
  String get settingsBackupSubtitle;

  /// No description provided for @settingsAboutSection.
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get settingsAboutSection;

  /// No description provided for @settingsVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja'**
  String get settingsVersion;

  /// No description provided for @settingsAppDesc.
  ///
  /// In pl, this message translates to:
  /// **'100% lokalny, bezpieczny dziennik serwisowy i kosztów pojazdów.'**
  String get settingsAppDesc;

  /// No description provided for @garageTitle.
  ///
  /// In pl, this message translates to:
  /// **'Garaż'**
  String get garageTitle;

  /// No description provided for @garageEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Twój garaż jest pusty'**
  String get garageEmptyTitle;

  /// No description provided for @garageEmptySubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj swój pierwszy samochód lub motocykl, aby rejestrować wydatki i terminy serwisowe.'**
  String get garageEmptySubtitle;

  /// No description provided for @garageAddFirstVehicle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy pojazd'**
  String get garageAddFirstVehicle;

  /// No description provided for @garageAddVehicle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj auto'**
  String get garageAddVehicle;

  /// No description provided for @garageTotalVehicles.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{1 pojazd} few{{count} pojazdy} many{{count} pojazdów} other{{count} pojazdu}}'**
  String garageTotalVehicles(num count);

  /// No description provided for @garageActiveAlerts.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =0{Brak pilnych spraw} one{1 pilna sprawa} few{{count} pilne sprawy} many{{count} pilnych spraw} other{{count} pilnych spraw}}'**
  String garageActiveAlerts(num count);

  /// No description provided for @garageBackupTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Kopia zapasowa i przywracanie'**
  String get garageBackupTooltip;

  /// No description provided for @garageQuickMileage.
  ///
  /// In pl, this message translates to:
  /// **'Szybka aktualizacja licznika'**
  String get garageQuickMileage;

  /// No description provided for @garageCurrentMileage.
  ///
  /// In pl, this message translates to:
  /// **'Aktualny przebieg'**
  String get garageCurrentMileage;

  /// No description provided for @garageNewMileage.
  ///
  /// In pl, this message translates to:
  /// **'Nowy przebieg'**
  String get garageNewMileage;

  /// No description provided for @dashboardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pulpit Pojazdu'**
  String get dashboardTitle;

  /// No description provided for @dashboardMileageKpi.
  ///
  /// In pl, this message translates to:
  /// **'LICZNIK'**
  String get dashboardMileageKpi;

  /// No description provided for @dashboardExpensesKpi.
  ///
  /// In pl, this message translates to:
  /// **'WYDATKI'**
  String get dashboardExpensesKpi;

  /// No description provided for @dashboardPurchaseKpi.
  ///
  /// In pl, this message translates to:
  /// **'ZAKUP'**
  String get dashboardPurchaseKpi;

  /// No description provided for @dashboardVinCopied.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano numer VIN'**
  String get dashboardVinCopied;

  /// No description provided for @dashboardPlateCopied.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano numer rejestracyjny'**
  String get dashboardPlateCopied;

  /// No description provided for @dashboardNoVin.
  ///
  /// In pl, this message translates to:
  /// **'VIN: Brak (kliknij, aby dodać)'**
  String get dashboardNoVin;

  /// No description provided for @dashboardRemindersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Alerty i Przypomnienia'**
  String get dashboardRemindersTitle;

  /// No description provided for @dashboardTimelineTitle.
  ///
  /// In pl, this message translates to:
  /// **'Oś czasu wydatków'**
  String get dashboardTimelineTitle;

  /// No description provided for @dashboardNewExpense.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wydatek'**
  String get dashboardNewExpense;

  /// No description provided for @dashboardSettingsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia pojazdu'**
  String get dashboardSettingsTooltip;

  /// No description provided for @expensesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki'**
  String get expensesTitle;

  /// No description provided for @expensesTotalKpi.
  ///
  /// In pl, this message translates to:
  /// **'ŁĄCZNIE WYDATKI'**
  String get expensesTotalKpi;

  /// No description provided for @expensesCountKpi.
  ///
  /// In pl, this message translates to:
  /// **'LICZBA WPISÓW'**
  String get expensesCountKpi;

  /// No description provided for @expensesSearchPlaceholder.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj wydatku (tytuł, notatka, warsztat)...'**
  String get expensesSearchPlaceholder;

  /// No description provided for @expensesFilterAllVehicles.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie auta'**
  String get expensesFilterAllVehicles;

  /// No description provided for @expensesFilterAllCategories.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie kategorie'**
  String get expensesFilterAllCategories;

  /// No description provided for @expensesDeletedMsg.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto wpis \"{title}\"'**
  String expensesDeletedMsg(Object title);

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak zarejestrowanych wydatków'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptySubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Kliknij przycisk poniżej, aby dodać tankowanie, serwis lub ubezpieczenie.'**
  String get expensesEmptySubtitle;

  /// No description provided for @addExpenseTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wydatek'**
  String get addExpenseTitle;

  /// No description provided for @editExpenseTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj wydatek'**
  String get editExpenseTitle;

  /// No description provided for @addExpenseAmount.
  ///
  /// In pl, this message translates to:
  /// **'Kwota'**
  String get addExpenseAmount;

  /// No description provided for @addExpenseTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł / Usługa'**
  String get addExpenseTitleLabel;

  /// No description provided for @addExpenseTitleHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Tankowanie, Wymiana oleju, Wycieraczki...'**
  String get addExpenseTitleHint;

  /// No description provided for @addExpenseCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get addExpenseCategory;

  /// No description provided for @addExpenseDate.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get addExpenseDate;

  /// No description provided for @addExpenseMileage.
  ///
  /// In pl, this message translates to:
  /// **'Stan licznika'**
  String get addExpenseMileage;

  /// No description provided for @addExpenseWorkshop.
  ///
  /// In pl, this message translates to:
  /// **'Warsztat / Stacja / Lokalizacja (opcjonalnie)'**
  String get addExpenseWorkshop;

  /// No description provided for @addExpenseNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka / Uwagi (opcjonalnie)'**
  String get addExpenseNote;

  /// No description provided for @addExpenseSuggestions.
  ///
  /// In pl, this message translates to:
  /// **'Popularne podpowiedzi'**
  String get addExpenseSuggestions;

  /// No description provided for @addExpenseSaveBtn.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wydatek'**
  String get addExpenseSaveBtn;

  /// No description provided for @editExpenseSaveBtn.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get editExpenseSaveBtn;

  /// No description provided for @expenseUpdatedMsg.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano wydatek!'**
  String get expenseUpdatedMsg;

  /// No description provided for @expenseSavedMsg.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano wydatek!'**
  String get expenseSavedMsg;

  /// No description provided for @dashboardCostPerDistance.
  ///
  /// In pl, this message translates to:
  /// **'Koszt na {distance} {unit}'**
  String dashboardCostPerDistance(Object distance, Object unit);

  /// No description provided for @dashboardCostExcludesPrice.
  ///
  /// In pl, this message translates to:
  /// **'Bez ceny zakupu'**
  String get dashboardCostExcludesPrice;

  /// No description provided for @dashboardEditDistanceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator kosztu na dystans'**
  String get dashboardEditDistanceTitle;

  /// No description provided for @dashboardEditDistanceLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dystans ({unit})'**
  String dashboardEditDistanceLabel(Object unit);

  /// No description provided for @dashboardEditDistanceBtn.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź'**
  String get dashboardEditDistanceBtn;

  /// No description provided for @addExpenseInvalidAmount.
  ///
  /// In pl, this message translates to:
  /// **'Podaj poprawną kwotę większą od zera'**
  String get addExpenseInvalidAmount;

  /// No description provided for @addExpenseInvalidTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę wydatku'**
  String get addExpenseInvalidTitle;

  /// No description provided for @addExpenseInvalidMileage.
  ///
  /// In pl, this message translates to:
  /// **'Podaj prawidłowy stan licznika'**
  String get addExpenseInvalidMileage;

  /// No description provided for @categoryFuel.
  ///
  /// In pl, this message translates to:
  /// **'Paliwo'**
  String get categoryFuel;

  /// No description provided for @categoryService.
  ///
  /// In pl, this message translates to:
  /// **'Serwis i Naprawy'**
  String get categoryService;

  /// No description provided for @categoryInsurance.
  ///
  /// In pl, this message translates to:
  /// **'Ubezpieczenie i Opłaty'**
  String get categoryInsurance;

  /// No description provided for @categoryTolls.
  ///
  /// In pl, this message translates to:
  /// **'Myjnia i Kosmetyki'**
  String get categoryTolls;

  /// No description provided for @categoryParts.
  ///
  /// In pl, this message translates to:
  /// **'Części i Eksploatacja'**
  String get categoryParts;

  /// No description provided for @categoryOther.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get categoryOther;

  /// No description provided for @remindersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Terminy i Alerty'**
  String get remindersTitle;

  /// No description provided for @remindersTabUrgent.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczne'**
  String get remindersTabUrgent;

  /// No description provided for @remindersTabWarning.
  ///
  /// In pl, this message translates to:
  /// **'Ostrzeżenia'**
  String get remindersTabWarning;

  /// No description provided for @remindersTabUpcoming.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanowane'**
  String get remindersTabUpcoming;

  /// No description provided for @remindersTabCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Wykonane'**
  String get remindersTabCompleted;

  /// No description provided for @remindersMarkDone.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako wykonane'**
  String get remindersMarkDone;

  /// No description provided for @remindersAddBtn.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj termin'**
  String get remindersAddBtn;

  /// No description provided for @remindersEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko na bieżąco!'**
  String get remindersEmptyTitle;

  /// No description provided for @remindersEmptySubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnych terminów lub przypomnień serwisowych.'**
  String get remindersEmptySubtitle;

  /// No description provided for @remindersStatusOverdue.
  ///
  /// In pl, this message translates to:
  /// **'Przeterminowane ({days} dni temu)'**
  String remindersStatusOverdue(Object days);

  /// No description provided for @remindersStatusToday.
  ///
  /// In pl, this message translates to:
  /// **'Termin dzisiaj!'**
  String get remindersStatusToday;

  /// No description provided for @remindersStatusTomorrow.
  ///
  /// In pl, this message translates to:
  /// **'Termin jutro!'**
  String get remindersStatusTomorrow;

  /// No description provided for @remindersStatusInDays.
  ///
  /// In pl, this message translates to:
  /// **'Za {days} dni'**
  String remindersStatusInDays(Object days);

  /// No description provided for @remindersStatusMileageLeft.
  ///
  /// In pl, this message translates to:
  /// **'Zostało {km}'**
  String remindersStatusMileageLeft(Object km);

  /// No description provided for @remindersStatusMileageOver.
  ///
  /// In pl, this message translates to:
  /// **'Przekroczono o {km}'**
  String remindersStatusMileageOver(Object km);

  /// No description provided for @addReminderTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowe przypomnienie'**
  String get addReminderTitle;

  /// No description provided for @addReminderTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa przypomnienia'**
  String get addReminderTitleLabel;

  /// No description provided for @addReminderTitleHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Przegląd techniczny, Ubezpieczenie OC, Wymiana rozrządu'**
  String get addReminderTitleHint;

  /// No description provided for @addReminderDesc.
  ///
  /// In pl, this message translates to:
  /// **'Opis / Notatka'**
  String get addReminderDesc;

  /// No description provided for @addReminderTypeDate.
  ///
  /// In pl, this message translates to:
  /// **'Według daty'**
  String get addReminderTypeDate;

  /// No description provided for @addReminderTypeMileage.
  ///
  /// In pl, this message translates to:
  /// **'Według przebiegu'**
  String get addReminderTypeMileage;

  /// No description provided for @addReminderDueDate.
  ///
  /// In pl, this message translates to:
  /// **'Data docelowa'**
  String get addReminderDueDate;

  /// No description provided for @addReminderDueMileage.
  ///
  /// In pl, this message translates to:
  /// **'Przebieg docelowy'**
  String get addReminderDueMileage;

  /// No description provided for @addReminderSeverity.
  ///
  /// In pl, this message translates to:
  /// **'Priorytet ważności'**
  String get addReminderSeverity;

  /// No description provided for @addReminderSeverityCritical.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczny (Czerwony)'**
  String get addReminderSeverityCritical;

  /// No description provided for @addReminderSeverityWarning.
  ///
  /// In pl, this message translates to:
  /// **'Ostrzeżenie (Żółty)'**
  String get addReminderSeverityWarning;

  /// No description provided for @addReminderSeverityInfo.
  ///
  /// In pl, this message translates to:
  /// **'Informacja (Niebieski)'**
  String get addReminderSeverityInfo;

  /// No description provided for @addReminderInterval.
  ///
  /// In pl, this message translates to:
  /// **'Powtarzaj cyklicznie'**
  String get addReminderInterval;

  /// No description provided for @statsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki & TCO'**
  String get statsTitle;

  /// No description provided for @statsTotalCost.
  ///
  /// In pl, this message translates to:
  /// **'Całkowity koszt posiadania (TCO)'**
  String get statsTotalCost;

  /// No description provided for @statsCostPerDistance.
  ///
  /// In pl, this message translates to:
  /// **'Koszt za 1 {unit}'**
  String statsCostPerDistance(Object unit);

  /// No description provided for @statsBreakdownTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podział kosztów według kategorii'**
  String get statsBreakdownTitle;

  /// No description provided for @statsBuyerReportBtn.
  ///
  /// In pl, this message translates to:
  /// **'Generuj Raport dla Kupującego (PDF)'**
  String get statsBuyerReportBtn;

  /// No description provided for @statsNoData.
  ///
  /// In pl, this message translates to:
  /// **'Brak wystarczających danych do wygenerowania statystyk.'**
  String get statsNoData;

  /// No description provided for @vehicleAddTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pojazd'**
  String get vehicleAddTitle;

  /// No description provided for @vehicleEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia pojazdu'**
  String get vehicleEditTitle;

  /// No description provided for @vehicleBrand.
  ///
  /// In pl, this message translates to:
  /// **'Marka'**
  String get vehicleBrand;

  /// No description provided for @vehicleModel.
  ///
  /// In pl, this message translates to:
  /// **'Model'**
  String get vehicleModel;

  /// No description provided for @vehicleGeneration.
  ///
  /// In pl, this message translates to:
  /// **'Generacja / Wersja (opcjonalnie)'**
  String get vehicleGeneration;

  /// No description provided for @vehicleYear.
  ///
  /// In pl, this message translates to:
  /// **'Rok produkcji'**
  String get vehicleYear;

  /// No description provided for @vehiclePlate.
  ///
  /// In pl, this message translates to:
  /// **'Numer rejestracyjny'**
  String get vehiclePlate;

  /// No description provided for @vehicleFuel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj paliwa'**
  String get vehicleFuel;

  /// No description provided for @vehicleVin.
  ///
  /// In pl, this message translates to:
  /// **'Numer VIN (opcjonalnie)'**
  String get vehicleVin;

  /// No description provided for @vehiclePurchasePrice.
  ///
  /// In pl, this message translates to:
  /// **'Cena zakupu pojazdu (opcjonalnie)'**
  String get vehiclePurchasePrice;

  /// No description provided for @vehicleDeleteBtn.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pojazd z garażu'**
  String get vehicleDeleteBtn;

  /// No description provided for @vehicleDeleteConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć ten pojazd oraz wszystkie powiązane z nim wydatki i przypomnienia? Tej operacji nie można cofnąć.'**
  String get vehicleDeleteConfirm;

  /// No description provided for @backupDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kopia Zapasowa'**
  String get backupDialogTitle;

  /// No description provided for @backupDialogSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Lokalny plik JSON'**
  String get backupDialogSubtitle;

  /// No description provided for @backupProcessing.
  ///
  /// In pl, this message translates to:
  /// **'Przetwarzanie operacji na pliku bazy danych...'**
  String get backupProcessing;

  /// No description provided for @backupExportBtn.
  ///
  /// In pl, this message translates to:
  /// **'Eksportuj kopię bazy'**
  String get backupExportBtn;

  /// No description provided for @backupImportBtn.
  ///
  /// In pl, this message translates to:
  /// **'Importuj i przywróć bazę'**
  String get backupImportBtn;

  /// No description provided for @backupExportSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Wyeksportowano kopię zapasową'**
  String get backupExportSuccess;

  /// No description provided for @backupImportSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Pomyślnie przywrócono dane z kopii ({vehicles} aut, {expenses} wydatków, {reminders} przypomnień)'**
  String backupImportSuccess(
    Object expenses,
    Object reminders,
    Object vehicles,
  );

  /// No description provided for @backupLocalNotice.
  ///
  /// In pl, this message translates to:
  /// **'Twoje dane są zapisane lokalnie w telefonie. Przed odinstalowaniem aplikacji lub zmianą telefonu wyeksportuj plik JSON i zapisz go na dysku lub wyślij mailem.'**
  String get backupLocalNotice;

  /// No description provided for @quickMileageTitle.
  ///
  /// In pl, this message translates to:
  /// **'Aktualizuj przebieg'**
  String get quickMileageTitle;

  /// No description provided for @quickMileageCurrent.
  ///
  /// In pl, this message translates to:
  /// **'Obecny stan: {mileage}'**
  String quickMileageCurrent(Object mileage);

  /// No description provided for @quickMileageNew.
  ///
  /// In pl, this message translates to:
  /// **'Nowy stan licznika'**
  String get quickMileageNew;

  /// No description provided for @quickMileageInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź prawidłowy przebieg'**
  String get quickMileageInvalid;

  /// No description provided for @vehicleDeleteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuwanie pojazdu'**
  String get vehicleDeleteTitle;

  /// No description provided for @vehicleDeletePrompt.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz trwale usunąć pojazd {name} ({plate})?'**
  String vehicleDeletePrompt(Object name, Object plate);

  /// No description provided for @vehicleDeleteWarning.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie zarejestrowane wydatki, historia serwisowa i alerty tego auta zostaną bezpowrotnie usunięte.'**
  String get vehicleDeleteWarning;

  /// No description provided for @vehicleDeleteHoldInstruction.
  ///
  /// In pl, this message translates to:
  /// **'Naciśnij i przytrzymaj czerwony przycisk, aby zatwierdzić'**
  String get vehicleDeleteHoldInstruction;

  /// No description provided for @vehicleDeleteHoldBtn.
  ///
  /// In pl, this message translates to:
  /// **'Przytrzymaj, aby usunąć'**
  String get vehicleDeleteHoldBtn;

  /// No description provided for @vehicleDeleteHoldingBtn.
  ///
  /// In pl, this message translates to:
  /// **'Trzymaj jeszcze {seconds}s...'**
  String vehicleDeleteHoldingBtn(Object seconds);

  /// No description provided for @vehicleDeletedMsg.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto pojazd {name}'**
  String vehicleDeletedMsg(Object name);

  /// No description provided for @vehicleSavedMsg.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano zmiany w pojeździe!'**
  String get vehicleSavedMsg;

  /// No description provided for @vehicleAddedMsg.
  ///
  /// In pl, this message translates to:
  /// **'Dodano pojazd {name} do garażu!'**
  String vehicleAddedMsg(Object name);

  /// No description provided for @reportTitle.
  ///
  /// In pl, this message translates to:
  /// **'Raport Pojazdu'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Historia serwisowa i dokument sprzedaży'**
  String get reportSubtitle;

  /// No description provided for @reportRegisteredEntries.
  ///
  /// In pl, this message translates to:
  /// **'Zarejestrowane pozycje ({count})'**
  String reportRegisteredEntries(Object count);

  /// No description provided for @reportEntriesCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{1 pozycja w raporcie} few{{count} pozycje w raporcie} many{{count} pozycji w raporcie} other{{count} pozycji w raporcie}}'**
  String reportEntriesCount(num count);

  /// No description provided for @reportNoEntries.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów dla tego pojazdu.'**
  String get reportNoEntries;

  /// No description provided for @reportPrintPdf.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd'**
  String get reportPrintPdf;

  /// No description provided for @reportSharePdf.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get reportSharePdf;

  /// No description provided for @reportCopyText.
  ///
  /// In pl, this message translates to:
  /// **'Kopiuj tekst'**
  String get reportCopyText;

  /// No description provided for @reportShareText.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij tekst'**
  String get reportShareText;

  /// No description provided for @reportCopiedMsg.
  ///
  /// In pl, this message translates to:
  /// **'Tekst raportu skopiowany do schowka!'**
  String get reportCopiedMsg;

  /// No description provided for @fuelTypeGasoline.
  ///
  /// In pl, this message translates to:
  /// **'Benzyna'**
  String get fuelTypeGasoline;

  /// No description provided for @fuelTypeDiesel.
  ///
  /// In pl, this message translates to:
  /// **'Diesel'**
  String get fuelTypeDiesel;

  /// No description provided for @fuelTypeHybrid.
  ///
  /// In pl, this message translates to:
  /// **'Hybryda'**
  String get fuelTypeHybrid;

  /// No description provided for @fuelTypeLpg.
  ///
  /// In pl, this message translates to:
  /// **'LPG'**
  String get fuelTypeLpg;

  /// No description provided for @fuelTypeElectric.
  ///
  /// In pl, this message translates to:
  /// **'Elektryczny'**
  String get fuelTypeElectric;

  /// No description provided for @ocrScanReceipt.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj paragon / fakturę'**
  String get ocrScanReceipt;

  /// No description provided for @ocrScanReceiptTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj paragon lub fakturę aparatem'**
  String get ocrScanReceiptTooltip;

  /// No description provided for @ocrSourceCamera.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie aparatem'**
  String get ocrSourceCamera;

  /// No description provided for @ocrSourceGallery.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz z galerii'**
  String get ocrSourceGallery;

  /// No description provided for @ocrScanning.
  ///
  /// In pl, this message translates to:
  /// **'Rozpoznawanie tekstu z paragonu...'**
  String get ocrScanning;

  /// No description provided for @ocrSuccessBanner.
  ///
  /// In pl, this message translates to:
  /// **'Odczytano dane z paragonu. Zweryfikuj i zatwierdź.'**
  String get ocrSuccessBanner;

  /// No description provided for @ocrNoDataFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać kwoty ani daty ze zdjęcia.'**
  String get ocrNoDataFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
