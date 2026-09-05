# Ekrany aplikacji AutoLog (Flutter)

Aplikacja posiada 4 główne moduły w dolnej nawigacji (`BottomNavigationBar`) z dynamicznymi odznakami alertów:

---

## 1. Garaż (`GarageScreen`)
* Baner floty z liczbą pojazdów i licznikiem aktywnych alertów.
* Karty pojazdów ze stylizowaną polską tablicą rejestracyjną (Euroband), rocznikiem, paliwem, przebiegiem i alertami.
* Szybka edycja licznika bezpośrednio z karty pojazdu.
* Przycisk synchronizacji chmurowej Google Drive w nagłówku.
* FAB: Dodaj nowy samochód (`AddVehicleScreen`).

## 2. Pulpit Pojazdu (`VehicleDashboardScreen`)
* Widok szczegółów wybranego auta (karta z licznikiem, paliwem, rocznikiem).
* Pasek filtrowania zdarzeń po kategoriach.
* Oś czasu zdarzeń (timeline) z kafelkami wydatków i serwisów.
* Przycisk ustawień / edycji / usunięcia auta (`VehicleSettingsScreen`).

## 3. Wydatki (`ExpensesScreen`)
* Karta KPI z sumą wydatków w PLN i liczbą pozycji.
* Wyszukiwarka tekstowa (tytuł, notatka, warsztat).
* Filtry horyzontalne według pojazdu i kategorii.
* FAB: Dodaj wydatek (`AddExpenseScreen`) z podpowiedziami popularnych tytułów.

## 4. Przypomnienia (`RemindersScreen`)
* Lista terminów pogrupowana według pilności (Krytyczne, Ostrzeżenia, Zaplanowane).
* Filtry według pilności i pojazdu.
* Akcja „Oznacz jako wykonane” z automatycznym przesunięciem interwału cyklicznego.
* FAB: Dodaj przypomnienie (`AddReminderDialog`) z wyborem trybu Data vs Przebieg.

## 5. Statystyki & TCO (`StatsScreen`)
* Filtrowanie statystyk dla całego garażu lub wybranego pojazdu.
* Karty wskaźników: Całkowity koszt (TCO) oraz Koszt za 1 km.
* Wykres kołowy wydatków (`fl_chart`) z legendą.
* Paski postępu i kwoty dla poszczególnych kategorii.
* Przycisk generowania Raportu dla Kupującego (`BuyerReportDialog`).
