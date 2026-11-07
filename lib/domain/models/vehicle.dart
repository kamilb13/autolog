enum AlertSeverity {
  critical,
  warning,
  info;

  static AlertSeverity fromString(String? val) {
    if (val == null) return AlertSeverity.info;
    switch (val.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'warning':
        return AlertSeverity.warning;
      case 'info':
      default:
        return AlertSeverity.info;
    }
  }

  String toDbString() => name.toUpperCase();
}

enum AlertType {
  insurance,
  technicalInspection,
  oilService,
  timingBelt,
  generalService;

  static AlertType fromString(String? val) {
    if (val == null) return AlertType.generalService;
    switch (val.toUpperCase()) {
      case 'INSURANCE':
        return AlertType.insurance;
      case 'TECHNICAL_INSPECTION':
        return AlertType.technicalInspection;
      case 'OIL_SERVICE':
        return AlertType.oilService;
      case 'TIMING_BELT':
        return AlertType.timingBelt;
      case 'GENERAL_SERVICE':
      default:
        return AlertType.generalService;
    }
  }

  String toDbString() {
    switch (this) {
      case AlertType.insurance:
        return 'INSURANCE';
      case AlertType.technicalInspection:
        return 'TECHNICAL_INSPECTION';
      case AlertType.oilService:
        return 'OIL_SERVICE';
      case AlertType.timingBelt:
        return 'TIMING_BELT';
      case AlertType.generalService:
        return 'GENERAL_SERVICE';
    }
  }
}

class VehicleAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertType type;

  const VehicleAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity.toDbString(),
      'type': type.toDbString(),
    };
  }

  factory VehicleAlert.fromMap(Map<String, dynamic> map) {
    return VehicleAlert(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      severity: AlertSeverity.fromString(map['severity'] as String?),
      type: AlertType.fromString(map['type'] as String?),
    );
  }
}

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String generationOrTrim;
  final int year;
  final String licensePlate;
  final int mileageKm;
  final String fuelType;
  final String vin;
  final double? purchasePricePln;
  final List<VehicleAlert> alerts;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    this.generationOrTrim = '',
    required this.year,
    required this.licensePlate,
    required this.mileageKm,
    required this.fuelType,
    this.vin = '',
    this.purchasePricePln,
    this.alerts = const [],
  });

  bool get hasCriticalAlerts =>
      alerts.any((a) => a.severity == AlertSeverity.critical);

  bool get hasWarnings =>
      alerts.any((a) => a.severity == AlertSeverity.warning);

  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    String? generationOrTrim,
    int? year,
    String? licensePlate,
    int? mileageKm,
    String? fuelType,
    String? vin,
    double? purchasePricePln,
    bool clearPurchasePrice = false,
    List<VehicleAlert>? alerts,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      generationOrTrim: generationOrTrim ?? this.generationOrTrim,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      mileageKm: mileageKm ?? this.mileageKm,
      fuelType: fuelType ?? this.fuelType,
      vin: vin ?? this.vin,
      purchasePricePln: clearPurchasePrice
          ? null
          : (purchasePricePln ?? this.purchasePricePln),
      alerts: alerts ?? this.alerts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'generation_or_trim': generationOrTrim,
      'year': year,
      'license_plate': licensePlate,
      'mileage_km': mileageKm,
      'fuel_type': fuelType,
      'vin': vin,
      'purchase_price_pln': purchasePricePln,
    };
  }

  factory Vehicle.fromMap(
    Map<String, dynamic> map, {
    List<VehicleAlert> alerts = const [],
  }) {
    return Vehicle(
      id: map['id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      generationOrTrim:
          (map['generation_or_trim'] ?? map['generationOrTrim'] ?? '')
              as String,
      year: (map['year'] as num).toInt(),
      licensePlate:
          (map['license_plate'] ?? map['licensePlate'] ?? '') as String,
      mileageKm: (map['mileage_km'] ?? map['mileageKm'] as num).toInt(),
      fuelType: (map['fuel_type'] ?? map['fuelType'] ?? 'Benzyna') as String,
      vin: (map['vin'] ?? '') as String,
      purchasePricePln: map['purchase_price_pln'] != null
          ? (map['purchase_price_pln'] as num).toDouble()
          : (map['purchasePricePln'] != null
                ? (map['purchasePricePln'] as num).toDouble()
                : null),
      alerts: alerts,
    );
  }
}
