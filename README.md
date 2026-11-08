# AutoLog

Aplikacja do prowadzenia dziennika wydatków i serwisu samochodów.

Strona produktu znajduje się w [`site/`](site/index.html).
[Publikacja na GitHub Pages i aktualizacja zrzutów ekranów](docs/website.md).

Dane są zapisywane na telefonie w bazie SQLite. Do prowadzenia dziennika nie potrzebujesz internetu ani konta. Opcjonalna kopia zapasowa w Google Drive wymaga połączenia z internetem i zalogowania do Google.

---

## Co potrafi aplikacja?

* **Garaż** – dodawaj auta (marka, model, rocznik, paliwo, VIN, polska tablica rejestracyjna) i aktualizuj stan licznika.
* **Dziennik wydatków** – zapisuj tankowania, naprawy, części, ubezpieczenia i parkingi z datą, kwotą, przebiegiem i notatką.
* **Terminy i przypomnienia** – ustawiaj przypomnienia o ubezpieczeniu OC/AC, przeglądzie technicznym i serwisie (np. wymianie oleju co 15 000 km lub 12 miesięcy).
* **Statystyki i TCO** – sprawdzaj sumę wydatków, podział kosztów na kategorie i koszt kilometra.
* **Raport dla kupującego (PDF)** – wybieraj wpisy do raportu przed sprzedażą auta. Domyślnie zawiera naprawy i części, bez tankowań i kwot. Możesz dołączyć kwoty, warsztat, notatki i VIN, a gotowy PDF wydrukować lub udostępnić.
* **Kopia zapasowa** – eksportuj dane do pliku JSON lub zapisz kopię w prywatnym folderze Google Drive. Możesz też przywrócić dane z kopii.

---

## Jak uruchomić projekt lokalnie?

### Wymagania:

* Flutter SDK z Dartem zgodnym z `pubspec.yaml` (obecnie `^3.13.2`)
* Android Studio / VS Code lub podłączony telefon z Androidem / emulator

### Uruchomienie:

```bash
# 1. Pobierz zależności
flutter pub get

# 2. Uruchom aplikację na podłączonym telefonie
flutter run
```

`flutter run` uruchamia tryb debug. Płynność na telefonie sprawdzaj w wersji release: `flutter run --release`.

---

## Struktura kodu (`lib/`)

Kod jest podzielony na warstwy. Stanem aplikacji zarządza **Riverpod**:

```text
lib/
├── core/             -> Motywy Material 3 (kolory, dark mode) i formatery (PLN, km, daty)
├── data/             -> Baza danych SQLite (app_database.dart), repozytoria i generator PDF
├── domain/           -> Czyste modele danych (Vehicle, Expense, ServiceReminder)
├── presentation/     -> Ekrany (screens/), klocki UI (widgets/) oraz stan aplikacji (providers/)
└── main.dart         -> Punkt startowy aplikacji
```

Dokumentacja modułów i lista zadań znajdują się w katalogu [`docs/`](docs/).

## Budowanie i wydania

CI sprawdza zmiany i buduje APK po pushu na `main` oraz dla pull requestów.
Podpisane wydania dla użytkowników powstają po wysłaniu taga wersji.
Konfigurację klucza, lokalną weryfikację i sposób publikacji opisuje
[instrukcja wydań](docs/releases.md).
