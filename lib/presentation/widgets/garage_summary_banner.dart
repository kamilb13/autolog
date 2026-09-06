import 'package:flutter/material.dart';
import 'package:autolog/l10n/app_localizations.dart';

class GarageSummaryBanner extends StatelessWidget {
  final int vehicleCount;
  final int activeAlertsCount;

  const GarageSummaryBanner({
    super.key,
    required this.vehicleCount,
    required this.activeAlertsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Vehicle count icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      l10n?.garageTotalVehicles(vehicleCount) ?? '$vehicleCount pojazdów',
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.garageActiveAlerts(activeAlertsCount) ??
                      (activeAlertsCount > 0 ? '$activeAlertsCount alertów' : 'Wszystkie terminy aktualne'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: activeAlertsCount > 0
                        ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100))
                        : (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ),

          // Trailing Action Indicator
          if (activeAlertsCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (isDark ? Colors.orange : Colors.orange.shade700).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sprawdź',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
