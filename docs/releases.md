# Budowanie i wydawanie AutoLog

Kod, automatyzacja i wydania APK są w repo `kamilb13/autolog`.

## CI

Workflow `CI` działa po pushu na `main`, dla pull requestów do `main`
i po ręcznym uruchomieniu w zakładce Actions.

Używa Fluttera 3.47.2 i JDK 21. Sprawdza formatowanie, analizę statyczną,
pełny zestaw testów oraz skrypt informacji o wydaniu. Potem buduje uniwersalny,
niepodpisany APK jako kontrolę kompilacji. Ten plik jest artefaktem CI,
nie instalatorem dla użytkowników. Artefakt wygasa po 7 dniach.

Te same kontrole lokalnie:

```bash
flutter pub get --enforce-lockfile
bash tool/verify.sh
```

Testy SQLite używają osobnego katalogu tymczasowego dla zestawu testów
oraz czyszczą dane przed każdym przypadkiem. Testy widgetów używają atrap
repozytoriów, bez połączenia z bazą użytkownika.

## Klucz podpisujący

Każde wydanie dla użytkowników musi używać tego samego klucza.
Lokalny klucz jest poza repo:

```text
~/.local/share/autolog-signing/release.jks
~/.local/share/autolog-signing/key.properties
```

Katalog ma uprawnienia `700`, a oba pliki `600`. `release.jks` to zaszyfrowany
magazyn PKCS12. `key.properties` zawiera ścieżkę do klucza, alias i hasła.
Nie dodawaj tych plików do Git ani do artefaktów wydań. Zrób kopię obu plików
w bezpiecznym miejscu poza komputerem. Utrata klucza lub haseł może uniemożliwić
aktualizację istniejących instalacji.

Lokalny build z podpisem:

```bash
export AUTOLOG_SIGNING_PROPERTIES="$HOME/.local/share/autolog-signing/key.properties"
flutter build apk --release --no-pub
```

Gradle odmawia budowania release bez konfiguracji podpisu. Wyjątkiem jest jawna
kontrola kompilacji z `ORG_GRADLE_PROJECT_autologUnsignedRelease=true`, używana
w CI. Taki build nie ma podpisu i nie nadaje się do instalacji.

## Sekrety GitHuba

Workflow wydania korzysta ze środowiska `release`, dopuszczającego wyłącznie tagi
`v*`. W jego Environment secrets muszą być ustawione:

| Nazwa | Wartość |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Zawartość `release.jks` zakodowana Base64 |
| `ANDROID_STORE_PASSWORD` | `storePassword` z lokalnego `key.properties` |
| `ANDROID_KEY_ALIAS` | `keyAlias` z lokalnego `key.properties` |
| `ANDROID_KEY_PASSWORD` | `keyPassword` z lokalnego `key.properties` |

Base64 nie jest szyfrowaniem. Do przechowywania tych wartości służą GitHub
Secrets, nie pliki workflow. Sekrety są przekazywane tylko do kroku podpisywania.
Runner odtwarza klucz w swoim katalogu tymczasowym i usuwa pliki po tym kroku.
CI pull requestów nie korzysta z klucza wydawniczego.

## Publikacja wersji

1. Zmień `version` w `pubspec.yaml`. Wersja i numer po `+` muszą być większe
   niż w poprzednim opublikowanym wydaniu, np. `1.0.1+2`, potem `1.0.2+3`.
2. Uruchom weryfikację. Zacommituj i wyślij zmiany na `main`.
3. Poczekaj na zielone CI, potem utwórz i wyślij tag zgodny z wersją:

```bash
git tag v1.0.1
git push origin v1.0.1
```

Workflow `Release` sprawdza, czy commit taga należy do historii `main`,
czy tag pasuje do `pubspec.yaml` i czy oba numery wersji rosną.
Ponownie uruchamia weryfikację, buduje podpisany APK oraz porównuje jego
certyfikat z kluczem wydania. Publiczne wydanie pojawia się dopiero po wysłaniu
wszystkich plików. W razie przerwania wysyłania można ponowić workflow;
uaktualni on szkic. Opublikowanych wydań skrypt nie zastępuje.

Każde wydanie zawiera:

- `autolog.apk` — uniwersalny instalator Androida;
- `SHA256SUMS` — sumę kontrolną APK;
- `update.json` — wersję, numer kompilacji, adres APK i jego sumę SHA-256.

Stały link do najnowszego wydania:

https://github.com/kamilb13/autolog/releases/latest

Stały adres informacji o aktualizacji:

https://github.com/kamilb13/autolog/releases/latest/download/update.json

Linki będą działały po opublikowaniu pierwszego wydania. Sam plik `update.json`
nie dodaje automatycznych powiadomień w aplikacji. Obsługa sprawdzania nowych
wersji w AutoLog jest osobnym krokiem; obecnie użytkownik pobiera APK z wydania.

## Pierwsza instalacja i obecny telefon

Dotychczasowe lokalne APK były podpisane kluczem debug. Nowy klucz wydawniczy
nie pozwoli zaktualizować ich bezpośrednio. Przed przejściem na publiczne wydania
wyeksportuj dane do JSON, zachowaj kopię poza aplikacją i sprawdź jej zawartość.
Dopiero potem można odinstalować starą wersję, zainstalować podpisane wydanie
i przywrócić dane. Nie odinstalowuj aplikacji przed sprawdzeniem kopii.

Osoby, które od początku zainstalują publiczny APK, będą mogły aktualizować go
kolejnymi wydaniami z tym samym podpisem. Aktualizacja zachowuje dane, o ile
migracje bazy są poprawne.

Jeśli używasz logowania Google Drive, nowy certyfikat podpisu trzeba też
uwzględnić w konfiguracji klienta OAuth dla pakietu `com.autolog.autolog`.
