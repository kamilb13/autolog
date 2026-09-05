# Stos technologiczny - AutoLog MVP (Flutter)

Aplikacja jest w 100% serverless, offline-first i nie wymaga zewnętrznego backendu (Spring Boot / PostgreSQL). Wszystkie dane są przechowywane lokalnie na urządzeniu w bazie SQLite, z opcją automatycznego/ręcznego backupu na Google Drive.

---

## 📱 Frontend & Framework
* **Flutter 3.47+ / Dart 3.13+**: Wieloplatformowy framework UI (Android, iOS, Linux Desktop, Web).
* **Material Design 3**: Nowoczesny design system z automotive akcentami i pełnym wsparciem Dark Mode / Light Mode.
* **flutter_riverpod (^2.6.1)**: Reaktywne zarządzanie stanem aplikacji (StateNotifierProvider, AsyncValue).
* **intl (^0.20.3) & flutter_localizations**: Formatowanie waluty (PLN `#,##0.00 zł`), liczb przebiegu (`#,### km`) i dat w polskiej lokalizacji (`pl_PL`).

---

## 💾 Baza danych i Storage lokalny
* **sqflite (^2.4.1) & sqflite_common_ffi (^2.3.4)**: Lokalna baza SQLite na Android/iOS oraz Linux/macOS/Windows.
* **path_provider (^2.1.5) & path (^1.9.0)**: Zarządzanie ścieżkami do plików bazodanowych i dokumentów aplikacji.
* **Wbudowany Seeder**: Automatyczne ładowanie danych demonstracyjnych (mock data) przy pierwszym uruchomieniu.

---

## ☁️ Synchronizacja chmurowa (Google Drive)
* **google_sign_in (^6.3.0)**: Bezpieczne logowanie kontem Google użytkownika.
* **googleapis (^13.2.0) & extension_google_sign_in_as_googleapis_auth**: Dostęp do Google Drive API w dedykowanym katalogu `appDataFolder` (`autolog_backup.json`).
* **share_plus (^10.1.4)**: Udostępnianie raportów kupującego i plików backupu przez systemowe menu Androida.

---

## 📊 Wizualizacja danych
* **fl_chart (^0.70.2)**: Interaktywne wykresy kołowe (PieChart) podziału kosztów według kategorii wydatków.

---

## 🏗️ Architektura kodu
* **Clean Architecture & Feature-First**:
  - `lib/domain/models/`: Niezmienne modele domenowe (`Vehicle`, `Expense`, `ServiceReminder`, `TcoStats`, `BuyerReport`).
  - `lib/data/`: `app_database.dart`, implementacje repozytoriów SQLite, `google_drive_service.dart`.
  - `lib/presentation/`: Notifiery Riverpod (`app_providers.dart`), ekrany (`screens/`), widżety współdzielone (`widgets/`).
  - `lib/core/`: Motywy Material 3 (`theme/app_theme.dart`), uniwersalne formatowania (`utils/formatters.dart`).
