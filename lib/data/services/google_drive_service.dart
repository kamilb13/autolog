import 'dart:convert';
import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class GoogleDriveSyncResult {
  final bool isSuccess;
  final String message;
  final DateTime? backupDate;

  const GoogleDriveSyncResult({
    required this.isSuccess,
    required this.message,
    this.backupDate,
  });
}

class GoogleDriveService {
  static final GoogleDriveService instance = GoogleDriveService._();

  GoogleDriveService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (_) {}
  }

  /// Backup local data to Google Drive AppData folder
  Future<GoogleDriveSyncResult> backupToDrive() async {
    try {
      var account = _currentUser ?? await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (account == null) {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Wymagane zalogowanie do konta Google.',
        );
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Błąd autoryzacji klienta Google.',
        );
      }

      final driveApi = drive.DriveApi(authClient);

      // Export JSON from SQLite
      final jsonContent = await AppDatabase.instance.exportToJson();
      final bytes = utf8.encode(jsonContent);
      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/json',
      );

      // Check for existing backup in appDataFolder
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'autolog_backup.json' and trashed = false",
      );

      final now = DateTime.now();

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing file
        final existingFile = fileList.files!.first;
        await driveApi.files.update(
          drive.File(
            name: 'autolog_backup.json',
            description: 'Kopia zapasowa AutoLog z dnia ${now.toIso8601String()}',
          ),
          existingFile.id!,
          uploadMedia: media,
        );
      } else {
        // Create new file in appDataFolder
        final driveFile = drive.File(
          name: 'autolog_backup.json',
          parents: ['appDataFolder'],
          description: 'Kopia zapasowa AutoLog z dnia ${now.toIso8601String()}',
        );
        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      return GoogleDriveSyncResult(
        isSuccess: true,
        message: 'Kopia zapasowa została pomyślnie zapisana na Dysku Google.',
        backupDate: now,
      );
    } catch (e) {
      return GoogleDriveSyncResult(
        isSuccess: false,
        message: 'Błąd synchronizacji z Dyskiem Google: ${e.toString()}',
      );
    }
  }

  /// Restore database from Google Drive AppData folder
  Future<GoogleDriveSyncResult> restoreFromDrive() async {
    try {
      var account = _currentUser ?? await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (account == null) {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Wymagane zalogowanie do konta Google.',
        );
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Błąd autoryzacji klienta Google.',
        );
      }

      final driveApi = drive.DriveApi(authClient);

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'autolog_backup.json' and trashed = false",
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Nie znaleziono wcześniejszej kopii zapasowej na Twoim Dysku Google.',
        );
      }

      final file = fileList.files!.first;
      final media = await driveApi.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataStore = [];
      await for (final data in media.stream) {
        dataStore.addAll(data);
      }

      final jsonString = utf8.decode(dataStore);
      await AppDatabase.instance.importFromJson(jsonString);

      return GoogleDriveSyncResult(
        isSuccess: true,
        message: 'Baza danych została pomyślnie przywrócona z Dysku Google!',
        backupDate: DateTime.now(),
      );
    } catch (e) {
      return GoogleDriveSyncResult(
        isSuccess: false,
        message: 'Błąd przywracania kopii zapasowej: ${e.toString()}',
      );
    }
  }

  /// Offline local backup export & share
  Future<void> exportAndShareLocalBackup() async {
    final jsonContent = await AppDatabase.instance.exportToJson();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/autolog_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'AutoLog — Kopia zapasowa bazy danych',
    );
  }

  /// Offline local backup import from picked JSON file
  Future<GoogleDriveSyncResult> importLocalBackupFromFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Anulowano wybór pliku kopii zapasowej.',
        );
      }

      final pickedFile = result.files.first;
      String jsonString;

      if (pickedFile.path != null && File(pickedFile.path!).existsSync()) {
        jsonString = await File(pickedFile.path!).readAsString();
      } else if (pickedFile.bytes != null) {
        jsonString = utf8.decode(pickedFile.bytes!);
      } else {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Nie udało się odczytać zawartości wybranego pliku.',
        );
      }

      return await importFromRawJson(jsonString);
    } catch (e) {
      return GoogleDriveSyncResult(
        isSuccess: false,
        message: 'Błąd podczas wczytywania pliku: $e',
      );
    }
  }

  /// Import database directly from raw JSON string with validation
  Future<GoogleDriveSyncResult> importFromRawJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic> || (!decoded.containsKey('vehicles') && !decoded.containsKey('expenses'))) {
        return const GoogleDriveSyncResult(
          isSuccess: false,
          message: 'Wybrany plik nie jest prawidłową kopią zapasową AutoLog.',
        );
      }

      final counts = await AppDatabase.instance.importFromJson(jsonString);
      final vehCount = counts['vehicles'] ?? 0;
      final expCount = counts['expenses'] ?? 0;
      final remCount = counts['reminders'] ?? 0;

      return GoogleDriveSyncResult(
        isSuccess: true,
        message: 'Pomyślnie przywrócono bazę!\n(Pojazdy: $vehCount, Wydatki: $expCount, Przypomnienia: $remCount)',
        backupDate: DateTime.now(),
      );
    } catch (e) {
      return GoogleDriveSyncResult(
        isSuccess: false,
        message: 'Błąd parsowania pliku JSON: $e',
      );
    }
  }
}
