import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/service_reminder.dart';
import '../../domain/models/vehicle.dart';

import '../providers/app_providers.dart';

class ReminderCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);
    final statusLabel = AppFormatters.reminderStatusLabel(reminder);

    Color badgeBg;
    Color badgeText;

    switch (reminder.severity) {
      case AlertSeverity.critical:
        badgeBg = isDark
            ? Colors.red.shade900.withValues(alpha: 0.35)
            : Colors.red.shade50;
        badgeText = isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828);
        break;
      case AlertSeverity.warning:
        badgeBg = isDark
            ? Colors.amber.shade900.withValues(alpha: 0.35)
            : Colors.amber.shade50;
        badgeText = isDark ? const Color(0xFFFFD54F) : const Color(0xFFE65100);
        break;
      case AlertSeverity.info:
        badgeBg = isDark
            ? Colors.blue.shade900.withValues(alpha: 0.35)
            : Colors.blue.shade50;
        badgeText = isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0);
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
              ? (isDark
                    ? Colors.red.shade800.withValues(alpha: 0.5)
                    : Colors.red.shade200)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.07)),
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
          // Top Row: Title & Date (left) + Badge & Wykonane Button (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (reminder.dueDate != null)
                      Text(
                        'Termin: ${AppFormatters.formatDisplayDate(reminder.dueDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      )
                    else if (reminder.dueMileageKm != null)
                      Text(
                        'Limit: ${AppFormatters.mileage(reminder.dueMileageKm!, unit: settings.distanceUnit.label)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: badgeText,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton(
                    onPressed: onMarkCompleted,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Wykonane'),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 2),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Opcje',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (val) {
                        if (val == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Usuń termin',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Description & cyclic interval (if any)
          if (reminder.description.isNotEmpty ||
              reminder.intervalMonths != null ||
              reminder.intervalKm != null) ...[
            const SizedBox(height: 6),
            if (reminder.description.isNotEmpty)
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            if (reminder.intervalMonths != null ||
                reminder.intervalKm != null) ...[
              const SizedBox(height: 2),
              Text(
                'Cykl: ${[if (reminder.intervalMonths != null) 'co ${reminder.intervalMonths} msc', if (reminder.intervalKm != null) 'co ${AppFormatters.mileage(reminder.intervalKm!, unit: settings.distanceUnit.label)}'].join(' / ')}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
