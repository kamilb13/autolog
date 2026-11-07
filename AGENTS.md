# AutoLog — harness dla Codexa

<!-- postman-cli:installation:start -->
Postman CLI is installed on this device, and can be used for API Engineering work.
<!-- postman-cli:installation:end -->

## ZASADY PRACY
- Przed zmianą przeczytaj kod, wywołania, powiązane testy i `git status --short`.
  Zachowaj wcześniejsze zmiany użytkownika; nie resetuj katalogu roboczego.
- Realizuj najmniejszą kompletną zmianę. Korzystaj z istniejących wzorców;
  nie dodawaj zależności ani nowych warstw bez konkretnej potrzeby.
- Tryb tylko do odczytu obowiązuje, gdy użytkownik go zażąda. Wtedy nie zapisuj,
  nie instaluj zależności i nie uruchamiaj testów, buildów ani generatorów.
- Ustalenia opieraj na kodzie, konfiguracji lub pomiarach. Podawaj plik i linię;
  hipotezy oraz niewykonane sprawdzenia oznaczaj wprost.
- Zgodę i zakres ustalony w rozmowie zachowuj między krokami. Nie pytaj ponownie
  o już autoryzowane czynności. Zapis instrukcji nie upoważnia do instalacji APK,
  publikacji ani operacji na danych użytkownika.

## ADR
- Zachowuj działanie offline: SQLite przechowuje dane, Google Drive obsługuje
  opcjonalne kopie. Nie dodawaj backendu bez osobnego zadania.
  Źródła: `docs/technologie.md:3`, `lib/data/database/app_database.dart:24`.
- Utrzymuj obecne warstwy i Riverpod. Logikę zapisu umieszczaj w repozytoriach,
  koordynację stanu w notifierach; nie dodawaj drugiego systemu stanu.
  Źródła: `README.md:37`, `lib/presentation/providers/app_providers.dart`.
- Po zapisie sprawdzaj zależne widoki: odświeżanie providerów jest ręczne,
  a zapis wydatku może zwiększyć licznik auta.
  Źródła: `lib/presentation/providers/app_providers.dart:164`,
  `lib/data/repositories/expense_repository.dart:80`.
- Zachowuj domyślne PL/PLN/km. Nie włączaj pozostałych opcji przy okazji poprawki;
  pełna lokalizacja i konwersje jednostek są w backlogu.
  Źródła: `lib/domain/models/app_settings.dart:103`, `docs/zadania.md:138`.

## LANDMINES
- Baza ma schemat v3. Zmiana schematu wymaga migracji istniejących danych,
  sprawdzenia kluczy obcych oraz testu migracji i zachowania rekordów.
  Migracje mają puste catch: brak zgłoszonego wyjątku nie dowodzi powodzenia.
  Źródło: `lib/data/database/app_database.dart:28`.
- Import JSON zastępuje dane, nie scala ich. Waliduj przed zastąpieniem;
  sprawdzaj rollback przy błędzie i zgodność ze starymi kopiami.
  Źródła: `lib/data/database/app_database.dart:157`,
  `lib/data/services/google_drive_service.dart:250`.
- Testy SQLite izoluj przez `test/helpers/test_database.dart`: osobny katalog
  tymczasowy, niezależne dane każdego przypadku i sprzątanie. W testach widgetów
  używaj `test/helpers/fake_repositories.dart`. Nie używaj bazy użytkownika.
- Nazwy kluczy SQLite i JSON są kontraktem danych. Zmiany sprawdzaj w toMap,
  fromMap, migracjach, eksporcie, imporcie i istniejących kopiach.
- `Expense.amountPln` i `mileageKm` określają jednostki przechowywania.
  Zmiana symbolu waluty lub etykiety dystansu nie przelicza danych.
  Źródło: `lib/domain/models/expense.dart:73`.
- Przebieg wydatku jest opcjonalny. Historyczny wpis może mieć niższy przebieg
  od obecnego licznika; zapis takiego wpisu nie powinien cofać licznika auta.
  Źródła: `lib/presentation/screens/add_expense_screen.dart:692`,
  `lib/data/repositories/expense_repository.dart:80`.
- Edytuj tłumaczenia w `lib/l10n/*.arb`; `app_localizations*.dart` generuj.
  Źródła: `l10n.yaml`, `docs/zadania.md:111`.
- Nie edytuj ręcznie rejestratorów pluginów, `.metadata` ani artefaktów
  `build/`, `.dart_tool/` i `ephemeral/`. Manifesty, Gradle i zasoby platform
  są utrzymywaną konfiguracją, którą można zmieniać w zakresie zadania.
- Release wymaga prywatnego klucza poza repo i `AUTOLOG_SIGNING_PROPERTIES`.
  Sekrety są w środowisku GitHuba `release`, dostępnym dla tagów `v*`.
  CI buduje niepodpisany APK wyłącznie jako kontrolę kompilacji. Nie publikuj go.
  Zmiana podpisu wymaga planu przeniesienia danych dawnych instalacji debug.
  Źródła: `android/app/build.gradle.kts`, `docs/releases.md`.
- OCR używa Latin. Przy zmianie skryptów sprawdź zależności i reguły R8;
  nie wyłączaj minifikacji jako obejścia brakujących klas.
  Źródła: `lib/data/services/receipt_ocr_service.dart:304`,
  `android/app/proguard-rules.pro`.
- Płynność mierz na fizycznym telefonie w profile/release. Tryb debug ma narzut;
  podejrzane miejsce w kodzie nie jest potwierdzonym wąskim gardłem.
  Kontroluj tworzenie całych list, start zakładek i przebudowy providerów.
- Wersje narzędzi CI są przypięte w `.github/workflows/ci.yml` i `release.yml`.
  Przy aktualizacji Fluttera zmieniaj oba workflowy. Zachowuj lockfile.
  Po zmianie faktu opisanego tutaj aktualizuj też instrukcję i jej źródło.

## GLOSSARY
- Pojazd: `Vehicle`; licznik auta: `mileageKm`.
- Wydatek: `Expense`; kategoria: `ExpenseCategory`; kwota danych: `amountPln`.
- Termin: `ServiceReminder`; limit daty: `dueDate`; licznika: `dueMileageKm`.
- Pilność: `AlertSeverity`; alert na karcie auta: `VehicleAlert`.
- TCO: `TcoStats` / `StatsRepository`; obecna suma kosztów wynika z wydatków.
- Raport kupującego: `BuyerReport`; dokument PDF: `PdfReportService`.
- Kopia danych: `AppDatabase.exportToJson` / `importFromJson`.
- OCR: `ReceiptOcrService`; interpretacja tekstu: `ReceiptParser`.

## HOW_TO_VERIFY
- Pracuj z katalogu zawierającego `pubspec.yaml`. Przygotuj zależności:
  `flutter pub get --enforce-lockfile`. Narzędzia SDK zapisują cache i artefakty.
- Zmiana ARB: najpierw `flutter gen-l10n`, potem przegląd wygenerowanego diffu.
- Jedna lokalna komenda weryfikacji: `bash tool/verify.sh`. Wykonuje kolejno:
  git diff --check, kontrolę formatu lib/test, flutter analyze --no-pub,
  pełne flutter test --no-pub i testy skryptu wydań w Pythonie.
- Zmiana Androida/release/pluginów/zależności wymaga dodatkowo:
  `flutter build apk --release --no-pub` z prywatną konfiguracją podpisu.
- Na początku można zawęzić testy; przed końcem zadania uruchom pełną weryfikację.
- Zmiana płynności: `flutter run --profile` na fizycznym telefonie;
  raportuj scenariusz, rozmiar danych, urządzenie i czasy klatek.
- W trybie tylko do odczytu nie uruchamiaj poleceń SDK ani skryptu verify.
- Po błędzie napraw przyczynę i ponów check. Nie usuwaj asercji ani nie wyciszaj
  analizy po to, żeby uzyskać sukces. Błąd środowiska lub wcześniejszy błąd
  zgłoś z dowodem; nie ogłaszaj zielonej weryfikacji bez wykonanych kontroli.
- Wydawanie wersji i konfiguracja sekretów: `docs/releases.md`.
  Tag vX.Y.Z musi pasować do pubspec; wersja i build number muszą rosnąć.
- Raport końcowy: co zmieniono, wykonane checki i wyniki, nieweryfikowany zakres.
  Sprawdź też nowe pliki i końcowy diff; nie commituj bez prośby użytkownika.

## ROLE POMOCNICZE CODEXA
- Deleguj konkretny, ograniczony zakres, gdy izolacja kontekstu pomoże zadaniu.
  Dla drobnej zmiany pracuj samodzielnie. Nie uruchamiaj wszystkich ról rutynowo.
- `repo-explorer`: przy niejasnym przepływie przeczytaj ekrany, providery,
  repozytoria, wywołania i testy. Tylko odczyt; komendy wyłącznie do odczytu,
  np. rg, git status/diff/ls-files/log/show. Raport: przepływ, pliki, niewiadome.
- `data-reviewer`: przy zmianie schematu, kopii, wydatku lub licznika sprawdź
  migracje, transakcje, kompatybilność JSON, null, daty, licznik, odświeżanie
  providerów i izolację testów. Tylko odczyt, bez wykonywania testów lub buildów.
- `android-release-reviewer`: przy zmianie platformy lub płynności sprawdź
  manifest, Gradle, podpis, R8, pluginy, ikony, listy i start zakładek.
  Tylko odczyt; zaproponuj pomiary, nie deklaruj ich wykonania.
- Każdej roli przekaż zakres i tryb pracy. Wymagaj raportu:
  ważność | plik:linia | scenariusz | skutek | poprawka lub brakujący dowód.
  Role nie zapisują plików, nie instalują zależności i nie delegują dalej.
  Główny agent odpowiada za implementację, integrację i końcową weryfikację.

## OWNERS
- TODO: właściciel danych, migracji i kopii.
- TODO: właściciel UI, domeny i lokalizacji.
- TODO: właściciel Android/release i podpisywania.
- Historia git wskazuje `kamil.brzoza`; nie zastępuje formalnego ustalenia ról.
