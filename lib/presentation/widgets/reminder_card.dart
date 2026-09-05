import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/service_reminder.dart';
import '../../domain/models/vehicle.dart';

class ReminderCard extends StatelessWidget {
  final ServiceReminder reminder;
  final Vehicle? vehicle;
  final VoidCallback onMarkCompleted;
  final VoidCallback? onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.vehicle,
    required this.onMarkCompleted,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusLabel = AppFormatters.reminderStatusLabel(reminder);

    Color badgeBg;
    Color badgeText;
    IconData severityIcon;

    switch (reminder.severity) {
      case AlertSeverity.critical:
        badgeBg = isDark ? Colors.red.shade900.withValues(alpha: 0.35) : Colors.red.shade50;
        badgeText = isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828);
        severityIcon = Icons.error_outline_rounded;
        break;
      case AlertSeverity.warning:
        badgeBg = isDark ? Colors.amber.shade900.withValues(alpha: 0.35) : Colors.amber.shade50;
        badgeText = isDark ? const Color(0xFFFFD54F) : const Color(0xFFE65100);
        severityIcon = Icons.warning_amber_rounded;
        break;
      case AlertSeverity.info:
        badgeBg = isDark ? Colors.blue.shade900.withValues(alpha: 0.35) : Colors.blue.shade50;
        badgeText = isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0);
        severityIcon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reminder.severity == AlertSeverity.critical
              ? (isDark ? Colors.red.shade800.withValues(alpha: 0.5) : Colors.red.shade200)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (vehicle != null)
                      Text(
                        '${vehicle!.brand} ${vehicle!.model} • ${vehicle!.licensePlate}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(severityIcon, size: 13, color: badgeText),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: badgeText,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Description
          if (reminder.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reminder.description,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Target Date / Mileage info
          Row(
            children: [
              if (reminder.dueDate != null) ...[
                Icon(Icons.calendar_today_rounded, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(
                  'Termin: ${AppFormatters.formatDisplayDate(reminder.dueDate)}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                ),
                const SizedBox(width: 12),
              ],
              if (reminder.dueMileageKm != null) ...[
                Icon(Icons.speed_rounded, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(
                  'Limit: ${AppFormatters.mileage(reminder.dueMileageKm!)}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                ),
              ],
            ],
          ),

          // Cyclic interval
          if (reminder.intervalMonths != null || reminder.intervalKm != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.repeat_rounded, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  'Cykl: ${[
                    if (reminder.intervalMonths != null) 'co ${reminder.intervalMonths} msc',
                    if (reminder.intervalKm != null) 'co ${AppFormatters.mileage(reminder.intervalKm!)}',
                  ].join(' / ')}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 8),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  tooltip: 'Usuń przypomnienie',
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.grey,
                    minimumSize: const Size(36, 36),
                  ),
                )
              else
                const SizedBox(),
              ElevatedButton.icon(
                onPressed: onMarkCompleted,
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Oznacz jako wykonane'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
