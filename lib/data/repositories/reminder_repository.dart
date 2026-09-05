import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/service_reminder.dart';
import '../../domain/models/vehicle.dart';
import '../database/app_database.dart';

class ReminderRepository {
  final AppDatabase _appDb;

  ReminderRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<List<ServiceReminder>> getReminders({
    String? vehicleId,
    AlertSeverity? severityFilter,
    String? searchQuery,
  }) async {
    final db = await _appDb.database;

    // Fetch all vehicles to map mileage
    final List<Map<String, dynamic>> vehMaps = await db.query('vehicles');
    final Map<String, int> vehicleMileages = {
      for (var v in vehMaps) v['id'] as String: (v['mileage_km'] as num).toInt()
    };

    final whereClauses = <String>['is_completed = 0'];
    final whereArgs = <dynamic>[];

    if (vehicleId != null && vehicleId.isNotEmpty) {
      whereClauses.add('vehicle_id = ?');
      whereArgs.add(vehicleId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim()}%';
      whereClauses.add('(title LIKE ? OR description LIKE ?)');
      whereArgs.add(query);
      whereArgs.add(query);
    }

    final whereString = whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'service_reminders',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'due_date ASC, due_mileage_km ASC, created_at DESC',
    );

    final now = DateTime.now();

    List<ServiceReminder> reminders = maps.map((map) {
      final vId = (map['vehicle_id'] ?? map['vehicleId']) as String;
      final currentMileage = vehicleMileages[vId] ?? 0;
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

    if (severityFilter != null) {
      reminders = reminders.where((r) => r.severity == severityFilter).toList();
    }

    // Sort by urgency: Critical first, then Warning, then Info, then lowest days/km
    reminders.sort((a, b) {
      final severityOrder = {
        AlertSeverity.critical: 0,
        AlertSeverity.warning: 1,
        AlertSeverity.info: 2,
      };
      final sevA = severityOrder[a.severity] ?? 2;
      final sevB = severityOrder[b.severity] ?? 2;
      if (sevA != sevB) return sevA.compareTo(sevB);

      final daysA = a.daysRemaining ?? 999999;
      final daysB = b.daysRemaining ?? 999999;
      return daysA.compareTo(daysB);
    });

    return reminders;
  }

  Future<void> addReminder(ServiceReminder reminder) async {
    final db = await _appDb.database;
    final data = reminder.toMap();
    data['created_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.insert('service_reminders', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markCompleted(String reminderId) async {
    final db = await _appDb.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'service_reminders',
      where: 'id = ?',
      whereArgs: [reminderId],
    );

    if (maps.isEmpty) return;
    final reminder = ServiceReminder.fromMap(maps.first);

    await db.transaction((txn) async {
      // Mark current as completed
      await txn.update(
        'service_reminders',
        {'is_completed': 1},
        where: 'id = ?',
        whereArgs: [reminderId],
      );

      // If cyclic, create the next upcoming reminder
      final intervalMonths = reminder.intervalMonths;
      final intervalKm = reminder.intervalKm;

      if ((intervalMonths != null && intervalMonths > 0) || (intervalKm != null && intervalKm > 0)) {
        String? nextDueDate;
        if (intervalMonths != null && intervalMonths > 0) {
          final baseDate = reminder.dueDate != null ? DateTime.parse(reminder.dueDate!) : DateTime.now();
          final nextDate = DateTime(baseDate.year, baseDate.month + intervalMonths, baseDate.day);
          nextDueDate = "${nextDate.year.toString().padLeft(4, '0')}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}";
        }

        int? nextDueMileage;
        if (intervalKm != null && intervalKm > 0) {
          final List<Map<String, dynamic>> vehMap = await txn.query(
            'vehicles',
            columns: ['mileage_km'],
            where: 'id = ?',
            whereArgs: [reminder.vehicleId],
          );
          final currentKm = vehMap.isNotEmpty ? (vehMap.first['mileage_km'] as num).toInt() : (reminder.dueMileageKm ?? 0);
          nextDueMileage = currentKm + intervalKm;
        }

        final nextReminder = ServiceReminder(
          id: const Uuid().v4(),
          vehicleId: reminder.vehicleId,
          title: reminder.title,
          description: reminder.description,
          dueDate: nextDueDate,
          dueMileageKm: nextDueMileage,
          severity: AlertSeverity.info,
          type: reminder.type,
          intervalMonths: intervalMonths,
          intervalKm: intervalKm,
          isCompleted: false,
        );

        final nextData = nextReminder.toMap();
        nextData['created_at'] = DateTime.now().millisecondsSinceEpoch;
        await txn.insert('service_reminders', nextData);
      }
    });
  }

  Future<void> deleteReminder(String reminderId) async {
    final db = await _appDb.database;
    await db.delete(
      'service_reminders',
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }
}
