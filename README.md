# AutoLog

Prosta, szybka i prywatna aplikacja mobilna do prowadzenia dziennika kosztów i serwisu Twoich samochodów. 

Wszystko działa **w 100% offline** na Twoim telefonie (baza SQLite). Nie ma tu żadnych zewnętrznych serwerów, rejestracji kont ani śledzenia – Twoje dane należą tylko do Ciebie.

---

## Co potrafi aplikacja?

* **Garaż** – dodawaj swoje auta (marka, model, rocznik, paliwo, VIN, polska tablica rejestracyjna) i aktualizuj stan licznika.
* **Dziennik wydatków** – zapisuj tankowania, naprawy, części, ubezpieczenia i parkingi z datą, kwotą, przebiegiem i notatką.
* **Terminy i przypomnienia** – ustawiaj przypomnienia o ubezpieczeniu OC/AC, przeglądzie technicznym lub interwałach serwisowych (np. olej co 15 000 km lub 12 miesięcy).
* **Statystyki i TCO** – sprawdzaj, ile realnie kosztuje Cię auto, jaki jest podział kosztów (wykres kołowy) i ile płacisz za każdy przejechany kilometr.
* **Raport dla kupującego (PDF)** – jednym kliknięciem generuj i drukuj/udostępniaj ustrukturyzowany dokument PDF z całą historią serwisową auta do sprzedaży.
* **Kopia zapasowa** – opcjonalny eksport/import bazy danych do pliku JSON oraz synchronizacja z prywatnym folderem Google Drive.

---

## Jak uruchomić projekt lokalnie?

### Wymagania:
* Flutter SDK (wersja 3.13+)
* Android Studio / VS Code lub podłączony telefon z Androidem / emulator

### Uruchomienie:
```bash
# 1. Pobierz zależności
flutter pub get

# 2. Uruchom aplikację na podłączonym telefonie
flutter run
```

---

## Struktura kodu (`lib/`)

Projekt korzysta z czytelnej architektury warstwowej i biblioteki **Riverpod**:

```text
lib/
├── core/             -> Motywy Material 3 (kolory, dark mode) i formatery (PLN, km, daty)
├── data/             -> Baza danych SQLite (app_database.dart), repozytoria i generator PDF
├── domain/           -> Czyste modele danych (Vehicle, Expense, ServiceReminder)
├── presentation/     -> Ekrany (screens/), klocki UI (widgets/) oraz stan aplikacji (providers/)
└── main.dart         -> Punkt startowy aplikacji
```

Pełna dokumentacja modułów i zadań znajduje się w katalogu [`docs/`](docs/).
