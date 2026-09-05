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
    final statusLabel = AppFormatters.reminderStatusLabel(reminder);

    Color badgeColor;
    Color textColor;
    IconData severityIcon;

    switch (reminder.severity) {
      case AlertSeverity.critical:
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        severityIcon = Icons.error_outline_rounded;
        break;
      case AlertSeverity.warning:
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        severityIcon = Icons.warning_amber_rounded;
        break;
      case AlertSeverity.info:
        badgeColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        severityIcon = Icons.info_outline_rounded;
        break;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: reminder.severity == AlertSeverity.critical
              ? Colors.red.shade300
              : Colors.grey.shade200,
        ),
      ),
      child: Padding(
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vehicle != null)
                        Text(
                          '${vehicle!.brand} ${vehicle!.model} (${vehicle!.licensePlate})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(severityIcon, size: 14, color: textColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            if (reminder.description.isNotEmpty) ...[
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Target Date / Mileage info
            Row(
              children: [
                if (reminder.dueDate != null) ...[
                  Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Termin: ${AppFormatters.formatDisplayDate(reminder.dueDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 12),
                ],
                if (reminder.dueMileageKm != null) ...[
                  Icon(Icons.speed_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Limit: ${AppFormatters.mileage(reminder.dueMileageKm!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),

            // Cyclic interval
            if (reminder.intervalMonths != null || reminder.intervalKm != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.repeat_rounded, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Cykl: ${[
                      if (reminder.intervalMonths != null) 'co ${reminder.intervalMonths} msc',
                      if (reminder.intervalKm != null) 'co ${AppFormatters.mileage(reminder.intervalKm!)}',
                    ].join(' / ')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                    label: const Text('Usuń', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                else
                  const SizedBox(),
                ElevatedButton.icon(
                  onPressed: onMarkCompleted,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Oznacz jako wykonane'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 38),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
