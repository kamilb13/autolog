# Ekrany aplikacji AutoLog (Flutter)

Aplikacja posiada 5 głównych modułów w dolnej nawigacji (`BottomNavigationBar` / `NavigationBar`) z dynamicznymi odznakami alertów oraz pełną lokalizacją i18n (PL/EN):

---

## 1. Garaż (`GarageScreen`)
* Baner floty z liczbą pojazdów i licznikiem aktywnych alertów.
* Karty pojazdów ze stylizowaną polską tablicą rejestracyjną (Euroband), rocznikiem, paliwem, przebiegiem i alertami.
* Szybka edycja licznika bezpośrednio z karty pojazdu.
* Przycisk synchronizacji chmurowej Google Drive w nagłówku.
* FAB: Dodaj nowy samochód (`AddVehicleScreen`).

## 2. Pulpit Pojazdu (`VehicleDashboardScreen`)
* Widok szczegółów wybranego auta (karta z licznikiem, wydatkami, kwotą zakupu).
* Klikalna polska tablica rejestracyjna z szybkim kopiowaniem numeru do schowka.
* Klikalny numer VIN z kopiowaniem do schowka lub szybkim przejściem do uzupełnienia.
* Pasek filtrowania zdarzeń po kategoriach.
* Oś czasu zdarzeń (timeline) z kafelkami wydatków i serwisów oraz opcją „COFNIJ” przy usuwaniu.
* Przycisk ustawień / edycji / usunięcia auta (`VehicleSettingsScreen`).

## 3. Wydatki (`ExpensesScreen`)
* Karta KPI z sumą wydatków w wybranej walucie (PLN/EUR/USD) i liczbą pozycji.
* Wyszukiwarka tekstowa (tytuł, notatka, warsztat).
* Filtry horyzontalne według pojazdu i kategorii.
* Usuwanie wpisów z osi czasu z 5-sekundowym paskiem **„COFNIJ” (Undo)**.
* Formularz **Nowy wydatek (`AddExpenseScreen`)**:
  * Inteligentne podpowiedzi (autocomplete) podczas wpisywania tytułu (np. "Wycier" $\to$ "Wycieraczki szyb").
  * Automatyczne dopasowanie kategorii (np. wybór "Wycieraczki szyb" $\to$ kategoria *Części i eksploatacja*).
  * Predefiniowana baza pozycji oraz dynamiczne uczenie się z historii wpisów użytkownika.
  * Walidacja stanu licznika dla tankowań oraz intuicyjny selektor pojazdów `VehicleSelector`.

## 4. Przypomnienia (`RemindersScreen`)
* Lista terminów pogrupowana według pilności (Krytyczne, Ostrzeżenia, Zaplanowane).
* Filtry według pilności i pojazdu.
* Akcja „Oznacz jako wykonane” z automatycznym przesunięciem interwału cyklicznego.
* FAB: Dodaj przypomnienie (`AddReminderDialog`) z wyborem trybu Data vs Przebieg.

## 5. Statystyki & TCO (`StatsScreen`)
* Filtrowanie statystyk dla całego garażu lub wybranego pojazdu.
* Karty wskaźników: Całkowity koszt (TCO) oraz Koszt za 1 km / 1 mi w wybranej walucie.
* Wykres kołowy wydatków (`fl_chart`) z legendą.
* Paski postępu i kwoty dla poszczególnych kategorii.
* Przycisk generowania Raportu dla Kupującego (`BuyerReportDialog`) z eksportem do PDF.

## 6. Ustawienia (`AppSettingsScreen`)
* **Język aplikacji**: Wybór języka (Domyślny systemowy, Polski PL, English EN) z natychmiastowym przełączeniem całego UI.
* **Waluta**: Wybór waluty (PLN / zł, EUR / €, USD / $) z automatycznym przeliczaniem prezentacji.
* **Jednostka odległości**: Wybór jednostki (Kilometry km, Mile mi) z dynamicznym formatowaniem kosztu za jednostkę.
* **Motyw aplikacji**: Systemowy, Jasny, Ciemny.
* **Kopia zapasowa**: Eksport bazy do pliku JSON oraz Import z pliku.
* **O aplikacji**: Wersja, status bazy SQLite (Offline-first) oraz informacja o licencji.
