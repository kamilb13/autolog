# AutoLog - Status realizacji zadań (Roadmap MVP Flutter)

Status: **100% ZREALIZOWANE (Faza 1 - Faza 7)**

---

## 🚀 Faza 1: Inicjalizacja i architektura bazowa
- [x] Utworzenie projektu Flutter w trybie serverless offline-first.
- [x] Konfiguracja zależności (`flutter_riverpod`, `sqflite`, `intl`, `fl_chart`, `share_plus`, `google_sign_in`, `googleapis`).
- [x] Utworzenie struktury katalogów (`lib/domain`, `lib/data`, `lib/presentation`, `lib/core`).
- [x] Konfiguracja motywu Material 3 (`AppTheme`) w trybie jasnym i ciemnym.
- [x] Wdrożenie polskich formatów waluty, przebiegu i dat (`AppFormatters`).

## 🚗 Faza 2: Baza danych SQLite i moduł Pojazdów (Garaż)
- [x] Projekt tabel SQLite (`vehicles`, `expenses`, `service_reminders`, `app_settings`).
- [x] Seeder przykładowych danych demonstracyjnych.
- [x] Repozytorium `VehicleRepository` (CRUD, szybka edycja licznika, dynamiczne wyliczanie alertów).
- [x] Ekran Garażu (`GarageScreen`) z banerem floty i kartami aut.
- [x] Widżet polskiej tablicy rejestracyjnej z Eurobandem (`PolishLicensePlate`).
- [x] Formularz dodawania auta (`AddVehicleScreen`) z podglądem karty na żywo.
- [x] Pulpit pojazdu (`VehicleDashboardScreen`) i Ustawienia (`VehicleSettingsScreen`).

## ⛽ Faza 3: Dziennik wydatków i serwisów
- [x] Model domenowy `Expense` i kategorie `ExpenseCategory` z kolorystyką i ikonami.
- [x] Repozytorium `ExpenseRepository` z filtrowaniem i auto-aktualizacją przebiegu auta.
- [x] Ekran rejestru wydatków (`ExpensesScreen`) z kartą sumy całkowitej i wyszukiwarką.
- [x] Formularz dodawania wydatku (`AddExpenseScreen`) z podpowiedziami najczęstszych czynności.
- [x] Widżet kafelka wydatku na osi czasu (`TimelineExpenseItem`).

## 🔔 Faza 4: Przypomnienia serwisowe i terminy
- [x] Model domenowy `ServiceReminder` z obsługą dat, limitów km i interwałów cyklicznych.
- [x] Repozytorium `ReminderRepository` z sortowaniem według pilności.
- [x] Ekran przypomnień (`RemindersScreen`) z filtrem ważności.
- [x] Dialog dodawania przypomnienia (`AddReminderDialog`) z przełącznikiem Data / Przebieg.
- [x] Mechanizm oznaczania jako wykonane z automatycznym odnawianiem wpisów cyklicznych.

## 📊 Faza 5: Statystyki TCO i Raport dla Kupującego
- [x] Repozytorium `StatsRepository` wyliczające całkowity koszt (TCO) oraz koszt za 1 km.
- [x] Ekran Statystyk (`StatsScreen`) z wykresem kołowym `fl_chart` i paskami kategorii.
- [x] Generator Raportu dla Kupującego (`BuyerReport`).
- [x] Modal raportu (`BuyerReportDialog`) z udostępnianiem tekstowym i kopiowaniem do schowka.

## ☁️ Faza 6: Synchronizacja chmurowa Google Drive
- [x] Serwis `GoogleDriveService` integrujący Google Sign-In i Google Drive AppData.
- [x] Eksport pełnej bazy do formatu JSON i import z walidacją spójności.
- [x] Widżet dialogu synchronizacji (`DriveSyncDialog`).
- [x] Lokalna opcja eksportu i udostępniania kopii zapasowej.

## 🧪 Faza 7: Testy i wdrożenie na urządzenie
- [x] Testy jednostkowe formaterów (`test/unit/formatters_test.dart`).
- [x] Testy jednostkowe modeli domenowych (`test/unit/models_test.dart`).
- [x] Testy eksportu i importu bazy danych (`test/unit/database_json_sync_test.dart`).
- [x] Test widżetowy (`test/widget_test.dart`).
- [x] Weryfikacja statyczna `flutter analyze` (0 błędów).
- [x] Zbudowanie APK i uruchomienie na fizycznym telefonie Motorola Edge 30 Neo.

## 🎨 Faza 8: Refaktoryzacja UI, eliminacja AI slop i eksport PDF
- [x] Usunięcie niepotrzebnych napisów w nagłówku ekranu głównego (`Mój Garaż 100% offline...`).
- [x] Redesign baneru floty (`GarageSummaryBanner`) na minimalistyczny, elegancki kafelek bez krzykliwych gradientów.
- [x] Całkowite usunięcie pomarańczowych/czerwonych grubych ramek wokół kart aut (`VehicleCard`) i wdrożenie nowoczesnego, subtelnego stylu automotive.
- [x] Wdrożenie serwisu generowania dokumentów PDF (`PdfReportService`) z obsługą formatu A4, polskich znaków i tabel historii serwisowej.
- [x] Dodanie do okna raportu kupującego (`BuyerReportDialog`) akcji: Podgląd/Drukuj PDF oraz Udostępnij PDF.
- [x] Odświeżenie kart przypomnień (`ReminderCard`) i wydatków (`TimelineExpenseItem`) w trybie jasnym i ciemnym.

## ⚡ Faza 9: Poprawa tablic PL, eliminacja ANR, alerty w pulpicie auta i UX
- [x] Nowy, realistyczny design polskiej tablicy rejestracyjnej z Eurobandem (okrąg 12 gwiazd UE, flaga PL, przetłoczenia) w `PolishLicensePlate`.
- [x] Eliminacja błędu ANR ("AutoLog isn't responding") poprzez asynchroniczne, nieblokujące ładowanie bazy SQLite poza `main()`.
- [x] Dodanie dedykowanej sekcji alertów i przypomnień w Pulpicie Pojazdu (`VehicleDashboardScreen`).
- [x] Usunięcie przesadzonej „Strefy niebezpiecznej” w ustawieniach pojazdu (`VehicleSettingsScreen`) na rzecz eleganckiego zarządzania pojazdem.
- [x] Usunięcie nakładającego się znacznika wyboru (fistaszek/check) z ikon kategorii w filtrach (`showCheckmark: false`).
- [x] Dodanie 5-sekundowego paska z opcją „COFNIJ” (Undo) przy usuwaniu przypomnienia w `RemindersScreen`.

## 🛠️ Faza 10: Dopracowanie formularzy, ergonomia UX, selektory aut i cena zakupu
- [x] **Poprawka formatowania udziału procentowego w raporcie PDF**:
  - Poprawiono mnożnik `cat.percentage * 100` w tabeli `PdfReportService`, dzięki czemu wartości (np. `70.0%`) renderują się prawidłowo.
- [x] **Eliminacja błędu overflow i intuicyjny kreator terminów (`AddReminderDialog`)**:
  - Usunięto overflow 42px i zastąpiono dropdown nowym selektorem `VehicleSelector`.
  - **Naprawiono błąd ujemnego przebiegu**: wpisanie np. `2 km` lub `10 000 km` w trybie „Za ile km od teraz” automatycznie dodaje tę wartość do aktualnego stanu licznika auta (np. $164\,250 + 10\,000 = 174\,250\text{ km}$) z podglądem na żywo.
  - W trybie „Przy stanie licznika” dodano walidację uniemożliwiającą wpisanie wartości mniejszej niż bieżący licznik.
  - **Uproszczono cykliczność**: zamiast niezrozumiałych pól tekstowych dodano przełącznik *„Powtarzaj cyklicznie”* z jasnym wyjaśnieniem i szybkimi chipami interwałów.
  - **Poprawiono formater statusów**: wyeliminowano napisy typu *„Za -164248 km”* na rzecz czytelnego *„Przekroczono o X km”* lub *„Przeterminowane (X dni temu)”*.
- [x] **Wymuszenie i ulepszenie walidacji stanu licznika przy tankowaniu (`AddExpenseScreen`)**:
  - Wymóg podania aktualnego stanu licznika dla kategorii Paliwo wraz z czytelnym komunikatem pomocniczym.
- [x] **Nowy selektor pojazdów w formularzu „Nowy wydatek” (`AddExpenseScreen`)**:
  - Wdrożono `VehicleSelector` ze stylizowanymi kartami pojazdów i miniaturą tablicy rejestracyjnej.
- [x] **Dynamiczne filtrowanie podpowiedzi marek i modeli (`AddVehicleScreen`)**:
  - Natychmiastowe zawężanie chipów marek podczas wpisywania (np. "vol" $\to$ Volkswagen, Volvo) oraz automatyczne podpowiedzi popularnych modeli danej marki.
- [x] **Precyzyjne komunikaty alertów w sekcji Terminy (`RemindersScreen`)**:
  - Rozróżnienie przeterminowanych/krytycznych terminów od zbliżających się ostrzeżeń w nagłówku i kolorystyce.
- [x] **Przebudowa kafelka przypomnienia (`ReminderCard`) i ergonomia usuwania**:
  - Przeniesienie akcji usuwania do menu 3-kropek w prawym górnym rogu kafelka i wyśrodkowanie pełnowymiarowego przycisku „Oznacz jako wykonane”.
- [x] **Obsługa ceny zakupu pojazdu (`purchase_price_pln`)**:
  - Rozszerzono model `Vehicle`, migrację bazy SQLite do wersji 2, formularz dodawania/edycji auta, pulpit KPI pojazdu oraz raport PDF.

## 💡 Faza 11: Inteligentna kategoryzacja wydatków i opcja Undo
- [x] **Opcja „COFNIJ” (Undo) przy usuwaniu wydatku z osi czasu (`ExpensesScreen` i `VehicleDashboardScreen`)**:
  - Dodano 5-sekundowy pasek `SnackBar` z akcją „COFNIJ” przy usuwaniu wpisu wydatku/serwisu z osi czasu, zabezpieczając przed przypadkowym skasowaniem danych.
- [x] **Inteligentne autouzupełnianie i automatyczna kategoryzacja wydatków (`AddExpenseScreen`)**:
  - Wdrożono dynamiczne podpowiedzi (autocomplete / sugestie) podczas wpisywania tytułu/opisu wydatku (np. wpisanie *"Wycier"* $\to$ podpowiedź *"Wycieraczki szyb"*).
  - Automatyczna zmiana kategorii wydatku na odpowiadającą (np. wybór *"Wycieraczki szyb"* $\to$ zmiana kategorii na *Części i eksploatacja*).
  - Wdrożono serwis `ExpenseSuggestionsService` z bogatą bazą popularnych pozycji kosztowych przypisanych do 5 kategorii oraz algorytm detekcji słów kluczowych.
  - Zaimplementowano dynamiczne uczenie się na podstawie historii wpisów użytkownika (`getLearnedSuggestions()` w `ExpenseRepository` i `expenseSuggestionsProvider`).
- [x] **Kopiowanie numeru rejestracyjnego i VIN do schowka (`VehicleDashboardScreen`)**:
  - Dodano możliwość kliknięcia w tablicę rejestracyjną oraz dedykowany chip VIN w celu natychmiastowego skopiowania wartości do schowka systemowego z potwierdzeniem `SnackBar` i haptyką.
  - Wyświetlanie numeru VIN na pulpicie pojazdu z opcją szybkiego przejścia do edycji, jeśli VIN nie został jeszcze podany.

---

## 🌐 Faza 12: Wielojęzyczność, Ustawienia i Formatowanie (i18n / l10n)
- [x] **Wielojęzyczność i słownik (i18n / l10n)**:
  - Wdrożenie systemu lokalizacji opartego o pliki słownikowe ARB (`app_pl.arb`, `app_en.arb`) i generator `flutter gen-l10n`.
  - Pełna obsługa języka **polskiego (PL)** oraz **angielskiego (EN)** z obsługą zmiennych, odmian liczby mnogiej (`plural`) i łatwą rozbudową o kolejne języki.
  - Przełącznik języka w nowym ekranie Ustawień (`AppSettingsScreen`) z opcją wykrywania języka systemowego telefonu (`AppLanguage.system`).
  - Dostosowanie formatowania walut i jednostek miary (PLN/EUR/USD, km/mi) w `AppFormatters` i na wszystkich ekranach.
  - Przełącznik motywu aplikacji (Systemowy / Jasny / Ciemny).
  - Zarządzanie lokalną kopią zapasową bazy danych (Eksport/Import JSON) w sekcji Ustawień.
  - Dodanie 5. zakładki nawigacji „Ustawienia” (`AppSettingsScreen`) w `MainNavigationScreen`.

---

## 🔮 Zadania na przyszłość (Backlog / Rozwój)
- [ ] **Skaner paragonów i faktur (OCR - On-Device)**:
  - Wdrożenie prostego, 100% lokalnego skanera paragonów z użyciem ML Kit (`google_mlkit_text_recognition`).
  - Przepływ: Zdjęcie paragonu $\to$ parsowanie tekstu (wyszukiwanie kwoty końcowej `PLN`, daty i nazwy stacji/warsztatu) $\to$ wstępne wypełnienie formularza „Nowy wydatek” do weryfikacji i akceptacji przez użytkownika (brak automatycznego zapisu w tle).



