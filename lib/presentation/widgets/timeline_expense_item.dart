import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/expense.dart';
import '../providers/app_providers.dart';

class TimelineExpenseItem extends ConsumerWidget {
  final Expense expense;
  final bool isFirst;
  final bool isLast;
  final String? monthHeader;
  final double? monthTotal;
  final bool showVehicleBadge;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TimelineExpenseItem({
    super.key,
    required this.expense,
    this.isFirst = false,
    this.isLast = false,
    this.monthHeader,
    this.monthTotal,
    this.showVehicleBadge = false,
    this.onDelete,
    this.onTap,
  });

  Future<void> _confirmDelete(BuildContext context, String currencyCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usunąć wydatek?'),
        content: Text(
          '„${expense.title}” — ${AppFormatters.currency(expense.amountPln, currencyCode: currencyCode)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final vehicle = showVehicleBadge
        ? vehiclesAsync.valueOrNull
              ?.where((v) => v.id == expense.vehicleId)
              .firstOrNull
        : null;
    final category = expense.category;
    final lineColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.12);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month / Timeline Milestone Header
        if (monthHeader != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  monthHeader!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (monthTotal != null) ...[
                  Text(
                    ' · ',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    AppFormatters.currency(
                      monthTotal!,
                      currencyCode: settings.currency.code,
                    ),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Timeline Node & Expense Card
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column: Vertical Timeline Track & Node
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    // Line segment above node
                    Container(
                      width: 1.5,
                      height: 8,
                      color: (isFirst && monthHeader == null)
                          ? Colors.transparent
                          : lineColor,
                    ),
                    // Category icon on the timeline
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF16191E) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: category.color, width: 2.0),
                      ),
                      child: Icon(
                        category.icon,
                        size: 14,
                        color: category.color,
                      ),
                    ),
                    // Line segment below node (fills remaining height down to next card)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: isLast ? Colors.transparent : lineColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right Column: Content Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.15 : 0.03,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Vehicle Badge
                                    if (vehicle != null) ...[
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.05,
                                                )
                                              : theme
                                                    .colorScheme
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.05,
                                                  ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.directions_car_rounded,
                                              size: 12,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '${vehicle.brand} ${vehicle.model}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ),
                                            if (vehicle
                                                .licensePlate
                                                .isNotEmpty) ...[
                                              Text(
                                                ' • ',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.35),
                                                ),
                                              ),
                                              Text(
                                                vehicle.licensePlate,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.65),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],

                                    // Top Row: Title + Amount
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            expense.title,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppFormatters.currency(
                                            expense.amountPln,
                                            currencyCode:
                                                settings.currency.code,
                                          ),
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Date · Mileage · Location
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            [
                                              AppFormatters.formatDisplayDate(
                                                expense.date,
                                              ),
                                              if (expense.mileageKm != null)
                                                AppFormatters.mileage(
                                                  expense.mileageKm,
                                                  unit: settings
                                                      .distanceUnit
                                                      .label,
                                                ),
                                              if (expense.workshopOrLocation !=
                                                      null &&
                                                  expense
                                                      .workshopOrLocation!
                                                      .isNotEmpty)
                                                expense.workshopOrLocation!,
                                            ].join(' · '),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.65),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Note
                                    if (expense.note != null &&
                                        expense.note!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.04,
                                                )
                                              : theme
                                                    .colorScheme
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          expense.note!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.75),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (onDelete != null)
                                IconButton(
                                  tooltip: 'Usuń wydatek',
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                  ),
                                  color: theme.colorScheme.onSurfaceVariant,
                                  onPressed: () => _confirmDelete(
                                    context,
                                    settings.currency.code,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
