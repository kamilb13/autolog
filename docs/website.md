# Strona produktu AutoLog

Strona w `site/` to statyczny HTML, CSS i niewielki skrypt animacji przewijania.
Nie wymaga instalowania pakietów,
budowania Flutter Web ani serwera aplikacji. Odnośnik pobierania prowadzi
zawsze do `autolog.apk` z najnowszego publicznego wydania na GitHubie.

Skrypt `script.js` pokazuje zalety i kroki instalacji po wejściu w obszar
ekranu. Bez JavaScriptu lub obsługi `IntersectionObserver` treść jest od razu
widoczna. Animacje respektują systemowe ustawienie ograniczenia ruchu.

## Publikacja na GitHub Pages

1. W repozytorium otwórz **Settings → Pages → Build and deployment**.
2. Jako **Source** wybierz **GitHub Actions**.
3. Zacommituj stronę oraz `.github/workflows/pages.yml` i wyślij na `main`.
4. Sprawdź wynik workflow **Product website**. Można go również uruchomić ręcznie.

Docelowy adres: https://kamilb13.github.io/autolog/

Workflow publikuje tylko `site/`, bez dokumentacji roboczej i danych aplikacji.
Zmiany strony nie podnoszą wersji APK i nie uruchamiają wydania Androida.

Konfiguracja opiera się na
[oficjalnym workflow GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

## Zrzuty ekranów

Zrzuty PNG w `site/assets/` są renderowane z rzeczywistych ekranów Fluttera
przy użyciu fikcyjnych pojazdów i wydatków. Generator używa atrap repozytoriów
i nie otwiera bazy danych ani nie łączy się z telefonem użytkownika.
Nie są to ręcznie odtworzone makiety. Czcionki platformowe są zastąpione
Roboto z SDK Fluttera, więc szczegóły typografii mogą różnić się od telefonu.

Aby odświeżyć zrzuty, z katalogu głównego projektu uruchom:

```bash
flutter pub get --enforce-lockfile
flutter test tool/generate_site_screenshots.dart
```

Generator zapisuje trzy obrazy 824 × 1784 px. Po zmianie obejrzyj obrazy,
upewnij się, że nie mają danych osobowych, i zacommituj PNG razem ze stroną.

Podgląd lokalny: otwórz `site/index.html` w przeglądarce. Wszystkie zasoby
mają ścieżki względne i działają również pod prefiksem `/autolog/` na Pages.
