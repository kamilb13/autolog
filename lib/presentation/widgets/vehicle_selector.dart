import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/vehicle.dart';
import 'polish_license_plate.dart';

class VehicleSelector extends StatelessWidget {
  final List<Vehicle> vehicles;
  final String? selectedVehicleId;
  final ValueChanged<Vehicle> onSelected;
  final bool compact;

  const VehicleSelector({
    super.key,
    required this.vehicles,
    required this.selectedVehicleId,
    required this.onSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (vehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Brak pojazdów w garażu. Najpierw dodaj pojazd.',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    if (vehicles.length == 1) {
      final v = vehicles.first;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 8 : 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E242B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_car_rounded, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${v.brand} ${v.model} (${v.year})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.mileage(v.mileageKm),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PolishLicensePlate(plateText: v.licensePlate, scale: compact ? 0.65 : 0.72),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vehicles.map((v) {
          final isSelected = v.id == selectedVehicleId;
          final borderColor = isSelected
              ? theme.colorScheme.primary
              : (isDark ? Colors.white12 : const Color(0xFFE2E8F0));
          final bgColor = isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.08)
              : (isDark ? const Color(0xFF1A2027) : const Color(0xFFF8FAFC));

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => onSelected(v),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 14,
                  vertical: compact ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.directions_car_rounded,
                      color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white38 : Colors.black38),
                      size: compact ? 18 : 20,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${v.brand} ${v.model}',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: compact ? 13 : 14,
                            color: isSelected ? theme.colorScheme.primary : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${v.year} • ${AppFormatters.mileage(v.mileageKm)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    PolishLicensePlate(plateText: v.licensePlate, scale: compact ? 0.6 : 0.68),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
