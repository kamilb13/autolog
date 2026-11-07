import 'package:sqflite/sqflite.dart';

import '../../domain/models/app_settings.dart';
import '../database/app_database.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  Future<AppSettings> loadSettings() async {
    final db = await _db.database;
    final rows = await db.query('app_settings');
    final map = <String, String>{};
    for (final row in rows) {
      final key = row['key'] as String?;
      final value = row['value'] as String?;
      if (key != null && value != null) {
        map[key] = value;
      }
    }
    return AppSettings.fromSettingsMap(map);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await _db.database;
    final batch = db.batch();
    final map = settings.toSettingsMap();

    for (final entry in map.entries) {
      batch.insert('app_settings', {
        'key': entry.key,
        'value': entry.value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
