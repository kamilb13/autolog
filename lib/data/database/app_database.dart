import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('autolog.db');
    return _database!;
  }

  Future<String> getDbPath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return join(dbFolder.path, 'autolog.db');
  }

  Future<Database> _initDB(String fileName) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = join(dbFolder.path, fileName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN purchase_price_pln REAL',
        );
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('PRAGMA foreign_keys = OFF');
        await db.execute('''
          CREATE TABLE expenses_temp (
            id TEXT PRIMARY KEY,
            vehicle_id TEXT NOT NULL,
            category TEXT NOT NULL,
            title TEXT NOT NULL,
            amount_pln REAL NOT NULL,
            date TEXT NOT NULL,
            mileage_km INTEGER,
            workshop_or_location TEXT,
            note TEXT,
            created_at INTEGER,
            FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          INSERT INTO expenses_temp (id, vehicle_id, category, title, amount_pln, date, mileage_km, workshop_or_location, note, created_at)
          SELECT id, vehicle_id, category, title, amount_pln, date, mileage_km, workshop_or_location, note, created_at FROM expenses
        ''');
        await db.execute('DROP TABLE expenses');
        await db.execute('ALTER TABLE expenses_temp RENAME TO expenses');
        await db.execute('PRAGMA foreign_keys = ON');
      } catch (_) {}
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        generation_or_trim TEXT,
        year INTEGER NOT NULL,
        license_plate TEXT NOT NULL,
        mileage_km INTEGER NOT NULL,
        fuel_type TEXT NOT NULL,
        vin TEXT,
        purchase_price_pln REAL,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        amount_pln REAL NOT NULL,
        date TEXT NOT NULL,
        mileage_km INTEGER,
        workshop_or_location TEXT,
        note TEXT,
        created_at INTEGER,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE service_reminders (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        due_mileage_km INTEGER,
        severity TEXT NOT NULL,
        type TEXT NOT NULL,
        interval_months INTEGER,
        interval_km INTEGER,
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // ---------------- EXPORT & IMPORT FOR BACKUP ---------------- //

  /// Export full database to structured JSON string
  Future<String> exportToJson() async {
    final db = await database;
    final vehicles = await db.query('vehicles');
    final expenses = await db.query('expenses');
    final reminders = await db.query('service_reminders');
    final settings = await db.query('app_settings');

    final exportData = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'app': 'AutoLog Flutter',
      'vehicles': vehicles,
      'expenses': expenses,
      'service_reminders': reminders,
      'app_settings': settings,
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Import database from structured JSON string (replaces or merges)
  Future<Map<String, int>> importFromJson(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final db = await database;
    int vehiclesCount = 0;
    int expensesCount = 0;
    int remindersCount = 0;

    await db.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('service_reminders');
      await txn.delete('vehicles');
      await txn.delete('app_settings');

      if (data['vehicles'] != null) {
        for (final v in (data['vehicles'] as List)) {
          await txn.insert('vehicles', Map<String, dynamic>.from(v as Map));
          vehiclesCount++;
        }
      }

      if (data['expenses'] != null) {
        for (final e in (data['expenses'] as List)) {
          await txn.insert('expenses', Map<String, dynamic>.from(e as Map));
          expensesCount++;
        }
      }

      if (data['service_reminders'] != null) {
        for (final r in (data['service_reminders'] as List)) {
          await txn.insert(
            'service_reminders',
            Map<String, dynamic>.from(r as Map),
          );
          remindersCount++;
        }
      }

      if (data['app_settings'] != null) {
        for (final s in (data['app_settings'] as List)) {
          await txn.insert('app_settings', Map<String, dynamic>.from(s as Map));
        }
      }
    });

    return {
      'vehicles': vehiclesCount,
      'expenses': expensesCount,
      'reminders': remindersCount,
    };
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
