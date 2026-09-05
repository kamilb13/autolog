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
      version: 2,
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
        await db.execute('ALTER TABLE vehicles ADD COLUMN purchase_price_pln REAL');
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
        mileage_km INTEGER NOT NULL,
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

    // Seed Initial Mock Data on first run
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // BMW
    await db.insert('vehicles', {
      'id': 'veh_1',
      'brand': 'BMW',
      'model': 'Seria 3 Touring',
      'generation_or_trim': '320d xDrive (G21)',
      'year': 2020,
      'license_plate': 'KR 7AK89',
      'mileage_km': 164250,
      'fuel_type': 'Diesel',
      'vin': 'WBA6L71080F123456',
      'purchase_price_pln': 125000.0,
      'created_at': now,
    });

    // Toyota
    await db.insert('vehicles', {
      'id': 'veh_2',
      'brand': 'Toyota',
      'model': 'Corolla TS',
      'generation_or_trim': '1.8 Hybrid GR Sport',
      'year': 2022,
      'license_plate': 'WA 54210',
      'mileage_km': 48120,
      'fuel_type': 'Hybryda',
      'vin': 'SB1ZE3BE60E654321',
      'purchase_price_pln': 98000.0,
      'created_at': now,
    });

    // Expenses
    final expenses = [
      {
        'id': 'exp_1',
        'vehicle_id': 'veh_1',
        'category': 'FUEL',
        'title': 'Tankowanie Diesel V-Power',
        'amount_pln': 378.50,
        'date': '2026-08-15',
        'mileage_km': 164200,
        'workshop_or_location': 'Shell Kraków Opolska',
        'note': '54.2 litra, średnie spalanie 6.2 l/100km',
        'created_at': now - 100000,
      },
      {
        'id': 'exp_2',
        'vehicle_id': 'veh_1',
        'category': 'SERVICE',
        'title': 'Wymiana tarcz i klocków przód',
        'amount_pln': 1450.00,
        'date': '2026-07-28',
        'mileage_km': 163100,
        'workshop_or_location': 'Bimmer Serwis Kraków',
        'note': 'Zestaw Zimmermann Sport + klocki Textar',
        'created_at': now - 200000,
      },
      {
        'id': 'exp_3',
        'vehicle_id': 'veh_1',
        'category': 'PARTS',
        'title': 'Wycieraczki Bosch Aerotwin',
        'amount_pln': 145.00,
        'date': '2026-07-10',
        'mileage_km': 161800,
        'workshop_or_location': 'Allegro',
        'note': 'Wymiana piór przód + tył',
        'created_at': now - 300000,
      },
      {
        'id': 'exp_4',
        'vehicle_id': 'veh_1',
        'category': 'FUEL',
        'title': 'Tankowanie Diesel',
        'amount_pln': 350.00,
        'date': '2026-06-25',
        'mileage_km': 160500,
        'workshop_or_location': 'Orlen Wielicka',
        'note': null,
        'created_at': now - 400000,
      },
      {
        'id': 'exp_5',
        'vehicle_id': 'veh_1',
        'category': 'SERVICE',
        'title': 'Serwis olejowy (Motul 5W30 + filtry)',
        'amount_pln': 680.00,
        'date': '2026-03-15',
        'mileage_km': 150200,
        'workshop_or_location': 'Bimmer Serwis Kraków',
        'note': null,
        'created_at': now - 500000,
      },
      {
        'id': 'exp_6',
        'vehicle_id': 'veh_2',
        'category': 'FUEL',
        'title': 'Tankowanie Pb95',
        'amount_pln': 210.00,
        'date': '2026-08-12',
        'mileage_km': 48050,
        'workshop_or_location': 'Circle K Warszawa',
        'note': '34.5 litra, średnie 4.4 l/100km',
        'created_at': now - 60000,
      },
      {
        'id': 'exp_7',
        'vehicle_id': 'veh_2',
        'category': 'SERVICE',
        'title': 'Przegląd gwarancyjny 45 tys. km',
        'amount_pln': 1100.00,
        'date': '2026-06-05',
        'mileage_km': 45100,
        'workshop_or_location': 'ASO Toyota Radość Warszawa',
        'note': 'Wymiana oleju 0W16, test baterii hybrydowej',
        'created_at': now - 700000,
      }
    ];

    for (final exp in expenses) {
      await db.insert('expenses', exp);
    }

    // Reminders
    final reminders = [
      {
        'id': 'rem_1',
        'vehicle_id': 'veh_1',
        'title': 'Koniec polisy OC/AC',
        'description': 'Wymagane odnowienie polisy ubezpieczeniowej',
        'due_date': '2026-09-15',
        'due_mileage_km': null,
        'severity': 'CRITICAL',
        'type': 'INSURANCE',
        'interval_months': 12,
        'interval_km': null,
        'is_completed': 0,
        'created_at': now,
      },
      {
        'id': 'rem_2',
        'vehicle_id': 'veh_1',
        'title': 'Wymiana oleju i filtrów',
        'description': 'Interwał co 15 000 km',
        'due_date': null,
        'due_mileage_km': 165000,
        'severity': 'WARNING',
        'type': 'OIL_SERVICE',
        'interval_months': 12,
        'interval_km': 15000,
        'is_completed': 0,
        'created_at': now,
      },
      {
        'id': 'rem_3',
        'vehicle_id': 'veh_1',
        'title': 'Wymiana paska rozrządu',
        'description': 'Zalecany limit 210 000 km',
        'due_date': null,
        'due_mileage_km': 210000,
        'severity': 'INFO',
        'type': 'TIMING_BELT',
        'interval_months': 72,
        'interval_km': 60000,
        'is_completed': 0,
        'created_at': now,
      },
      {
        'id': 'rem_4',
        'vehicle_id': 'veh_2',
        'title': 'Badanie techniczne',
        'description': 'Okresowe badanie w stacji kontroli pojazdów',
        'due_date': '2026-11-20',
        'due_mileage_km': null,
        'severity': 'INFO',
        'type': 'TECHNICAL_INSPECTION',
        'interval_months': 12,
        'interval_km': null,
        'is_completed': 0,
        'created_at': now,
      },
      {
        'id': 'rem_5',
        'vehicle_id': 'veh_2',
        'title': 'Serwis klimatyzacji i odgrzybianie',
        'description': 'Zalecany przegląd i ozonowanie kabiny',
        'due_date': '2026-10-01',
        'due_mileage_km': null,
        'severity': 'INFO',
        'type': 'GENERAL_SERVICE',
        'interval_months': 12,
        'interval_km': null,
        'is_completed': 0,
        'created_at': now,
      }
    ];

    for (final rem in reminders) {
      await db.insert('service_reminders', rem);
    }
  }

  // ---------------- EXPORT & IMPORT FOR GOOGLE DRIVE ---------------- //

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
  Future<void> importFromJson(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('service_reminders');
      await txn.delete('vehicles');
      await txn.delete('app_settings');

      if (data['vehicles'] != null) {
        for (final v in (data['vehicles'] as List)) {
          await txn.insert('vehicles', Map<String, dynamic>.from(v as Map));
        }
      }

      if (data['expenses'] != null) {
        for (final e in (data['expenses'] as List)) {
          await txn.insert('expenses', Map<String, dynamic>.from(e as Map));
        }
      }

      if (data['service_reminders'] != null) {
        for (final r in (data['service_reminders'] as List)) {
          await txn.insert('service_reminders', Map<String, dynamic>.from(r as Map));
        }
      }

      if (data['app_settings'] != null) {
        for (final s in (data['app_settings'] as List)) {
          await txn.insert('app_settings', Map<String, dynamic>.from(s as Map));
        }
      }
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
