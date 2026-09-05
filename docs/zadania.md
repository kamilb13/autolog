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

---

## 🔮 Zadania na przyszłość (Backlog / Rozwój)
- [ ] **Wielojęzyczność i słownik (i18n / l10n)**:
  - Wdrożenie systemu lokalizacji opartego o pliki słownikowe ARB (`app_pl.arb`, `app_en.arb`) lub moduł `intl`.
  - Obsługa języka **polskiego (PL)** oraz **angielskiego (EN)** z możliwością łatwego dodawania kolejnych języków.
  - Przełącznik języka w ustawieniach aplikacji z opcją wykrywania języka systemowego telefonu.
  - Dostosowanie formatowania walut i jednostek miary (PLN/EUR/USD, km/mi).
- [ ] **Cena zakupu pojazdu (Purchase Price)**:
  - Rozszerzenie modelu pojazdu (`Vehicle`), tabeli SQLite i formularzy o pole `purchase_price_pln`.
  - Prezentacja ceny nabycia na pulpicie pojazdu oraz w statystykach.
- [ ] **Poprawka formatowania udziału procentowego w raporcie PDF**:
  - Przeliczenie ułamka udziału kategorii (`fraction * 100`) w tabeli PDF, aby `0.70` wyświetlało się jako `70.0%` zamiast `0.7%`.
- [ ] **Uproszczenie etykiety alertów na karcie pojazdu w garażu**:
  - Zmiana opisu alertu w `VehicleCard` na minimalistyczny zapis np. `2 alerty` / `2 aktywne alerty` (bez długiego rozwinięcia tytułu).
- [ ] **Nowy selektor pojazdu w formularzu „Nowy wydatek” (`AddExpenseScreen`)**:
  - Zastąpienie surowego dropdownu nowoczesnym selektorem kafelkowym / poziomą listą kart pojazdów ze stylizowaną polską tablicą rejestracyjną.
- [ ] **Przebudowa kafelka przypomnienia (`ReminderCard`) i ergonomia usuwania**:
  - Przeniesienie akcji usuwania do menu nagłówka (3-kropki lub ikona w prawym górnym rogu) bądź gest przesunięcia (swipe-to-delete), aby dolny pasek był czysty i zbalansowany z przyciskiem „Oznacz jako wykonane”.
- [ ] **Dynamiczne filtrowanie podpowiedzi marek/modeli w `AddVehicleScreen`**:
  - W trakcie wpisywania tekstu w polu Marka (np. "vol"), dolne kafelki podpowiedzi natychmiast filtrują się i pokazują tylko pasujące marki (np. Volkswagen, Volvo).
- [ ] **Skaner paragonów i faktur (OCR - On-Device)**:
  - Wdrożenie prostego, 100% lokalnego skanera paragonów z użyciem ML Kit (`google_mlkit_text_recognition`).
  - Przepływ: Zdjęcie paragonu $\to$ parsowanie tekstu (wyszukiwanie kwoty końcowej `PLN`, daty i nazwy stacji/warsztatu) $\to$ wstępne wypełnienie formularza „Nowy wydatek” do weryfikacji i akceptacji przez użytkownika (brak automatycznego zapisu w tle).
- [ ] **Poprawa komunikatów alertów w sekcji Terminy (`RemindersScreen`)**:
  - Rozdzielenie alertów krytycznych (np. przeterminowane) od ostrzeżeń (zbliżające się za X km/dni) zamiast nazywania każdego ostrzeżenia „pilnym alertem”.
- [ ] **Poprawa błędu overflow i selektora aut w „Nowy termin” (`AddReminderDialog`)**:
  - Usunięcie błędu przepełnienia pikseli (`overflowed by 42px`) poprzez elastyczną wysokość modala i `SingleChildScrollView`.
  - Nowoczesny, zgrabny selektor pojazdów zamiast surowego dropdownu rozjeżdżającego się na całą szerokość.
- [ ] **Wymuszenie podania przebiegu przy wydatkach na paliwo (`AddExpenseScreen`)**:
  - Dodanie bezwzględnej walidacji przebiegu dla kategorii Paliwo (wymóg podania aktualnego stanu licznika).
  - Kluczowe dla precyzyjnego wyliczania kosztu 1 km (TCO) oraz aktualizacji interwałów przypomnień.
