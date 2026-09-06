# AutoLog - MVP (Flutter Serverless)

## 1. Moduły i wymagania funkcjonalne

### Zarządzanie pojazdami (Garaż)
* Dodawanie, edycja i usuwanie pojazdów (marka, model, wersja/generacja, rocznik, tablice rejestracyjne, przebieg, typ paliwa, VIN).
* Przełączanie się między autami w garażu z wizualizacją polskich tablic rejestracyjnych (Euroband).
* Szybka aktualizacja bieżącego stanu licznika (+100 / +500 / +1000 km lub wpisanie ręczne).

### Dziennik wydatków i serwisów
* Rejestrowanie wydatków z podziałem na 5 głównych kategorii (Paliwo, Naprawa/Serwis, Części i eksploatacja, Ubezpieczenie, Opłaty i inne).
* **Inteligentne autouzupełnianie i automatyczna kategoryzacja**: podpowiedzi w locie na podstawie wpisywanego tekstu (np. "Wycier" $\to$ "Wycieraczki szyb"), automatyczne przypisanie kategorii, słownik popularnych pozycji i dynamiczne uczenie się z historii użytkownika.
* **Opcja „COFNIJ” (Undo)**: 5-sekundowy pasek SnackBar przy usuwaniu wydatku zapobiegający przypadkowej utracie danych.
* Wprowadzanie szczegółów: data (format ISO YYYY-MM-DD), przebieg przy zdarzeniu, kwota w PLN, warsztat/stacja, notatka.
* Filtrowanie wydatków według pojazdu oraz kategorii z podsumowaniem całkowitym (KPI).
* Automatyczne aktualizowanie przebiegu pojazdu, jeśli wydatek wprowadzono z wyższym stanem licznika.

### Terminy i przypomnienia (Serwis i Opłaty)
* Definiowanie terminów czasowych (data) oraz limitów przebiegu (km).
* Obsługa interwałów cyklicznych (np. wymiana oleju co 12 miesięcy lub co 15 000 km).
* Dynamiczne wyliczanie dni i kilometrów pozostałych do wykonania oraz statusów ważności (Krytyczne, Ostrzeżenia, Zaplanowane).
* Przycisk "Oznacz jako wykonane" – dla przypomnień cyklicznych automatycznie odnawia wpis na kolejny interwał.

### Statystyki i TCO (Total Cost of Ownership)
* Podsumowanie całkowitych kosztów utrzymania auta w PLN.
* Wyliczenie średniego kosztu za 1 km przebiegu.
* Interaktywny wykres kołowy (Pie Chart) podziału kosztów według kategorii (`fl_chart`).
* Procentowe paski postępu dla poszczególnych kategorii kosztów.

### Raport dla Kupującego (Eksport)
* Generowanie przejrzystego, ustrukturyzowanego raportu serwisowego ze statystykami i historią napraw na potrzeby sprzedaży auta.
* Udostępnianie raportu w formie tekstowej (`share_plus`) oraz kopiowanie do schowka.

### Bezpieczeństwo i Backup (Google Drive & Offline-First)
* 100% działanie w trybie offline bez zewnętrznego serwera backendowego (lokalna baza SQLite).
* Synchronizacja kopii zapasowej z chmurą Google Drive (AppData folder) z opcją ręcznego pobrania i przywrócenia bazy.
* Eksport i import bazy danych w formacie JSON.

### Wielojęzyczność i Słownik (Planowane)
* Architektura słownikowa (i18n / l10n) przygotowana na wiele języków (na start: Polski `pl` i Angielski `en`).
* Dynamiczny wybór języka w aplikacji oraz automatyczne dopasowanie do języka urządzenia.
* Elastyczne formatowanie walut (PLN, EUR, USD) i jednostek miary (km, mile).
