import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/vehicle.dart';

import 'package:autolog/l10n/app_localizations.dart';

import '../providers/app_providers.dart';
import 'polish_license_plate.dart';

class VehicleCard extends ConsumerWidget {
  final Vehicle vehicle;
  final VoidCallback onClick;
  final VoidCallback? onUpdateMileageClick;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onClick,
    this.onUpdateMileageClick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: isDark
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.07),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Brand Model & Generation/Year & Fuel Tag
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicle.generationOrTrim.isNotEmpty
                              ? '${vehicle.generationOrTrim} • ${vehicle.year}'
                              : 'Rocznik: ${vehicle.year}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      vehicle.fuelType,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // License Plate & Mileage Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PolishLicensePlate(
                    plateText: vehicle.licensePlate,
                    scale: 0.95,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n?.garageCurrentMileage ?? 'Przebieg',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            AppFormatters.mileage(
                              vehicle.mileageKm,
                              unit: settings.distanceUnit.label,
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      if (onUpdateMileageClick != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onUpdateMileageClick,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(28, 28),
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            foregroundColor: theme.colorScheme.primary,
                          ),
                          tooltip:
                              l10n?.garageQuickMileage ?? 'Zaktualizuj licznik',
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Alerts section if any
              if (vehicle.alerts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (vehicle.hasCriticalAlerts
                                ? (isDark
                                      ? Colors.red.shade900
                                      : Colors.red.shade50)
                                : (isDark
                                      ? Colors.amber.shade900
                                      : Colors.amber.shade50))
                            .withValues(alpha: isDark ? 0.3 : 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        vehicle.hasCriticalAlerts
                            ? Icons.error_outline_rounded
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: vehicle.hasCriticalAlerts
                            ? (isDark
                                  ? const Color(0xFFFF8A80)
                                  : const Color(0xFFC62828))
                            : (isDark
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFFE65100)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${vehicle.alerts.length} ${vehicle.alerts.length == 1
                              ? 'aktywny alert'
                              : vehicle.alerts.length < 5
                              ? 'aktywne alerty'
                              : 'aktywnych alertów'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: vehicle.hasCriticalAlerts
                                ? (isDark
                                      ? const Color(0xFFFF8A80)
                                      : const Color(0xFFC62828))
                                : (isDark
                                      ? const Color(0xFFFFD54F)
                                      : const Color(0xFFE65100)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
