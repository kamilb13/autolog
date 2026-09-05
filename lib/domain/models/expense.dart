import 'package:flutter/material.dart';

enum ExpenseCategory {
  fuel(
    displayName: 'Paliwo',
    icon: Icons.local_gas_station_rounded,
    color: Color(0xFFF57C00), // Orange
  ),
  service(
    displayName: 'Naprawa / Serwis',
    icon: Icons.build_rounded,
    color: Color(0xFF1976D2), // Blue
  ),
  parts(
    displayName: 'Części i eksploatacja',
    icon: Icons.extension_rounded,
    color: Color(0xFF388E3C), // Green
  ),
  insurance(
    displayName: 'Ubezpieczenie',
    icon: Icons.security_rounded,
    color: Color(0xFF7B1FA2), // Purple
  ),
  tollsFees(
    displayName: 'Opłaty i inne',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFF455A64), // Blue Grey
  );

  final String displayName;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.displayName,
    required this.icon,
    required this.color,
  });

  static ExpenseCategory fromString(String? val) {
    if (val == null) return ExpenseCategory.tollsFees;
    switch (val.toUpperCase()) {
      case 'FUEL':
        return ExpenseCategory.fuel;
      case 'SERVICE':
        return ExpenseCategory.service;
      case 'PARTS':
        return ExpenseCategory.parts;
      case 'INSURANCE':
        return ExpenseCategory.insurance;
      case 'TOLLS_FEES':
      default:
        return ExpenseCategory.tollsFees;
    }
  }

  String toDbString() {
    switch (this) {
      case ExpenseCategory.fuel:
        return 'FUEL';
      case ExpenseCategory.service:
        return 'SERVICE';
      case ExpenseCategory.parts:
        return 'PARTS';
      case ExpenseCategory.insurance:
        return 'INSURANCE';
      case ExpenseCategory.tollsFees:
        return 'TOLLS_FEES';
    }
  }
}

class Expense {
  final String id;
  final String vehicleId;
  final ExpenseCategory category;
  final String title;
  final double amountPln;
  final String date; // format YYYY-MM-DD or DD.MM.YYYY
  final int mileageKm;
  final String? workshopOrLocation;
  final String? note;

  const Expense({
    required this.id,
    required this.vehicleId,
    required this.category,
    required this.title,
    required this.amountPln,
    required this.date,
    required this.mileageKm,
    this.workshopOrLocation,
    this.note,
  });

  Expense copyWith({
    String? id,
    String? vehicleId,
    ExpenseCategory? category,
    String? title,
    double? amountPln,
    String? date,
    int? mileageKm,
    String? workshopOrLocation,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      category: category ?? this.category,
      title: title ?? this.title,
      amountPln: amountPln ?? this.amountPln,
      date: date ?? this.date,
      mileageKm: mileageKm ?? this.mileageKm,
      workshopOrLocation: workshopOrLocation ?? this.workshopOrLocation,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'category': category.toDbString(),
      'title': title,
      'amount_pln': amountPln,
      'date': date,
      'mileage_km': mileageKm,
      'workshop_or_location': workshopOrLocation,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      vehicleId: (map['vehicle_id'] ?? map['vehicleId']) as String,
      category: ExpenseCategory.fromString(map['category'] as String?),
      title: map['title'] as String,
      amountPln: (map['amount_pln'] ?? map['amountPln'] as num).toDouble(),
      date: map['date'] as String,
      mileageKm: (map['mileage_km'] ?? map['mileageKm'] as num).toInt(),
      workshopOrLocation: map['workshop_or_location'] ?? map['workshopOrLocation'] as String?,
      note: map['note'] as String?,
    );
  }
}
