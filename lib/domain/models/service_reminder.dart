import 'vehicle.dart';

class ServiceReminder {
  final String id;
  final String vehicleId;
  final String title;
  final String description;
  final String? dueDate; // ISO format YYYY-MM-DD
  final int? dueMileageKm;
  final int? daysRemaining;
  final int? kmRemaining;
  final AlertSeverity severity;
  final AlertType type;
  final int? intervalMonths;
  final int? intervalKm;
  final bool isCompleted;

  const ServiceReminder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    this.dueDate,
    this.dueMileageKm,
    this.daysRemaining,
    this.kmRemaining,
    this.severity = AlertSeverity.info,
    this.type = AlertType.generalService,
    this.intervalMonths,
    this.intervalKm,
    this.isCompleted = false,
  });

  bool get isMileageBased => dueMileageKm != null;
  bool get isDateBased => dueDate != null;

  ServiceReminder copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? description,
    String? dueDate,
    int? dueMileageKm,
    int? daysRemaining,
    int? kmRemaining,
    AlertSeverity? severity,
    AlertType? type,
    int? intervalMonths,
    int? intervalKm,
    bool? isCompleted,
  }) {
    return ServiceReminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueMileageKm: dueMileageKm ?? this.dueMileageKm,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      kmRemaining: kmRemaining ?? this.kmRemaining,
      severity: severity ?? this.severity,
      type: type ?? this.type,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      intervalKm: intervalKm ?? this.intervalKm,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'due_mileage_km': dueMileageKm,
      'severity': severity.toDbString(),
      'type': type.toDbString(),
      'interval_months': intervalMonths,
      'interval_km': intervalKm,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory ServiceReminder.fromMap(
    Map<String, dynamic> map, {
    int? daysRemaining,
    int? kmRemaining,
    AlertSeverity? calculatedSeverity,
  }) {
    return ServiceReminder(
      id: map['id'] as String,
      vehicleId: (map['vehicle_id'] ?? map['vehicleId']) as String,
      title: map['title'] as String,
      description: (map['description'] ?? '') as String,
      dueDate: map['due_date'] ?? map['dueDate'] as String?,
      dueMileageKm: (map['due_mileage_km'] ?? map['dueMileageKm'] as num?)
          ?.toInt(),
      daysRemaining:
          daysRemaining ??
          (map['days_remaining'] ?? map['daysRemaining'] as num?)?.toInt(),
      kmRemaining:
          kmRemaining ??
          (map['km_remaining'] ?? map['kmRemaining'] as num?)?.toInt(),
      severity:
          calculatedSeverity ??
          AlertSeverity.fromString(map['severity'] as String?),
      type: AlertType.fromString(map['type'] as String?),
      intervalMonths: (map['interval_months'] ?? map['intervalMonths'] as num?)
          ?.toInt(),
      intervalKm: (map['interval_km'] ?? map['intervalKm'] as num?)?.toInt(),
      isCompleted:
          (map['is_completed'] == 1 ||
          map['is_completed'] == true ||
          map['isCompleted'] == true),
    );
  }
}
