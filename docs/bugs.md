# Rozwiązane błędy i przypadki brzegowe (Flutter)

Podczas przepisywania aplikacji na Fluttera rozwiązano wszystkie problemy znane z poprzedniej wersji prototypu:

---

### 1. Rozwiązany błąd „za null dni” w przypomnieniach
* **Problem w wersji prototypowej**: Jeśli przypomnienie było ustawione na limit kilometrów (bez konkretnej daty), interfejs wyświetlał błędną etykietę `za null dni`.
* **Rozwiązanie w Flutterze**: `AppFormatters.reminderStatusLabel` sprawdza typ przypomnienia (czasowe vs przebiegowe) oraz poziom ważności (`AlertSeverity`), formatując prawidłowo np. `Za 5 000 km` lub `Wygasło!`.

### 2. Rozwiązany błąd formatowania i walidacji dat ISO
* **Problem w wersji prototypowej**: Formularz akceptował różne formaty dat (np. `DD.MM.YYYY`), co prowadziło do błędów parsowania przez silniki bazodanowe.
* **Rozwiązanie w Flutterze**: Formularze korzystają z systemowego `showDatePicker` oraz zunifikowanego `AppFormatters.formatIsoDate`, który zawsze zapisuje i odczytuje standard `YYYY-MM-DD`.

### 3. Zastąpienie niestabilnego połączenia lokalnego `adb reverse`
* **Problem w wersji prototypowej**: Aplikacja wymagała włączonego backendu Spring Boot oraz komendy `adb reverse tcp:8080 tcp:8080`, która często rozłączała się po Wi-Fi.
* **Rozwiązanie w Flutterze**: Całkowita eliminacja backendu zewnętrznego na rzecz wbudowanej bazy SQLite (`sqflite`) i chmury Google Drive. Aplikacja działa natychmiast po instalacji bez żadnych zależności sieciowych.

### 4. Zgodność z Android 14 i najnowszymi wersjami Flutter SDK
* **Rozwiązanie**: Zaktualizowano `compileSdk` do wersji 36, wyczyszczono przestarzałe metody `Color.withOpacity` na rzecz `Color.withValues(alpha: ...)`, a testy jednostkowe pokrywają całą logikę serializacji i synchronizacji bazy.
