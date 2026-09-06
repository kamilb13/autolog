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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final vehicle = showVehicleBadge
        ? vehiclesAsync.valueOrNull?.where((v) => v.id == expense.vehicleId).firstOrNull
        : null;
    final category = expense.category;
    final lineColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month / Timeline Milestone Header
        if (monthHeader != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 11, color: theme.colorScheme.primary),
                      const SizedBox(width: 5),
                      Text(
                        monthHeader!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (monthTotal != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          AppFormatters.currency(monthTotal!, currencyCode: settings.currency.code),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
                      width: 2,
                      height: 10,
                      color: (isFirst && monthHeader == null) ? Colors.transparent : lineColor,
                    ),
                    // Timeline Node Circle
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark
                            ? category.color.withValues(alpha: 0.22)
                            : category.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: category.color.withValues(alpha: isDark ? 0.7 : 0.45),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 15,
                      ),
                    ),
                    // Line segment below node (fills remaining height down to next card)
                    Expanded(
                      child: Container(
                        width: 2,
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
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vehicle Badge
                              if (vehicle != null) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(alpha: 0.05),
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
                                      Text(
                                        '${vehicle.brand} ${vehicle.model}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                                        ),
                                      ),
                                      if (vehicle.licensePlate.isNotEmpty) ...[
                                        Text(
                                          ' • ',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                                          ),
                                        ),
                                        Text(
                                          vehicle.licensePlate,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],

                              // Top Row: Title + Amount
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      expense.title,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppFormatters.currency(expense.amountPln, currencyCode: settings.currency.code),
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),

                              // Category, Date, Mileage Row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: category.color.withValues(alpha: isDark ? 0.15 : 0.08),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      category.displayName,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: category.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppFormatters.formatDisplayDate(expense.date),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    ' • ',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                                  ),
                                  Text(
                                    AppFormatters.mileage(expense.mileageKm, unit: settings.distanceUnit.label),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (onDelete != null)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      onPressed: onDelete,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),

                              // Workshop / Location
                              if (expense.workshopOrLocation != null &&
                                  expense.workshopOrLocation!.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        expense.workshopOrLocation!,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // Note
                              if (expense.note != null && expense.note!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.04)
                                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    expense.note!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
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
