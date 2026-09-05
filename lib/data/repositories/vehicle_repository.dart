import 'package:sqflite/sqflite.dart';
import '../../domain/models/service_reminder.dart';
import '../../domain/models/vehicle.dart';
import '../database/app_database.dart';

class VehicleRepository {
  final AppDatabase _appDb;

  VehicleRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<List<Vehicle>> getAllVehicles() async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      orderBy: 'created_at DESC, brand ASC',
    );

    final List<Vehicle> vehicles = [];
    for (final map in maps) {
      final vehicleId = map['id'] as String;
      final currentMileage = (map['mileage_km'] as num).toInt();

      // Fetch reminders for vehicle to calculate alerts
      final reminders = await _getRemindersForVehicle(db, vehicleId, currentMileage);
      final alerts = _calculateAlerts(reminders);

      vehicles.add(Vehicle.fromMap(map, alerts: alerts));
    }

    return vehicles;
  }

  Future<Vehicle?> getVehicleById(String id) async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final currentMileage = (map['mileage_km'] as num).toInt();
    final reminders = await _getRemindersForVehicle(db, id, currentMileage);
    final alerts = _calculateAlerts(reminders);

    return Vehicle.fromMap(map, alerts: alerts);
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final db = await _appDb.database;
    final data = vehicle.toMap();
    data['created_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.insert('vehicles', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final db = await _appDb.database;
    await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<void> updateMileage(String vehicleId, int newMileage) async {
    final db = await _appDb.database;
    await db.update(
      'vehicles',
      {'mileage_km': newMileage},
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
  }

  Future<void> deleteVehicle(String id) async {
    final db = await _appDb.database;
    await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ServiceReminder>> _getRemindersForVehicle(
    Database db,
    String vehicleId,
    int currentMileage,
  ) async {
    final List<Map<String, dynamic>> reminderMaps = await db.query(
      'service_reminders',
      where: 'vehicle_id = ? AND is_completed = 0',
      whereArgs: [vehicleId],
    );

    final now = DateTime.now();

    return reminderMaps.map((map) {
      final dueDateStr = map['due_date'] as String?;
      final dueMileage = (map['due_mileage_km'] as num?)?.toInt();

      int? daysRemaining;
      if (dueDateStr != null) {
        try {
          final due = DateTime.parse(dueDateStr);
          daysRemaining = due.difference(DateTime(now.year, now.month, now.day)).inDays;
        } catch (_) {}
      }

      int? kmRemaining;
      if (dueMileage != null) {
        kmRemaining = (dueMileage - currentMileage);
      }

      // Calculate severity
      AlertSeverity severity = AlertSeverity.fromString(map['severity'] as String?);
      if (daysRemaining != null) {
        if (daysRemaining <= 7) {
          severity = AlertSeverity.critical;
        } else if (daysRemaining <= 30) {
          severity = AlertSeverity.warning;
        }
      }
      if (kmRemaining != null) {
        if (kmRemaining <= 500) {
          severity = AlertSeverity.critical;
        } else if (kmRemaining <= 1500) {
          severity = AlertSeverity.warning;
        }
      }

      return ServiceReminder.fromMap(
        map,
        daysRemaining: daysRemaining,
        kmRemaining: kmRemaining,
        calculatedSeverity: severity,
      );
    }).toList();
  }

  List<VehicleAlert> _calculateAlerts(List<ServiceReminder> reminders) {
    return reminders
        .where((r) => r.severity == AlertSeverity.critical || r.severity == AlertSeverity.warning)
        .map((r) {
      String desc = r.description;
      if (r.daysRemaining != null && r.daysRemaining! <= 0) {
        desc = 'Termin minął ${r.daysRemaining!.abs()} dni temu!';
      } else if (r.daysRemaining != null) {
        desc = 'Wygasa za ${r.daysRemaining} dni (${r.dueDate ?? ''})';
      } else if (r.kmRemaining != null) {
        desc = 'Pozostało ${r.kmRemaining} km do limitu (${r.dueMileageKm} km)';
      }

      return VehicleAlert(
        id: r.id,
        title: r.title,
        description: desc,
        severity: r.severity,
        type: r.type,
      );
    }).toList();
  }
}
