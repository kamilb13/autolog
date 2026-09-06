import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autolog/l10n/app_localizations.dart';
import '../../domain/models/vehicle.dart';

class DeleteVehicleDialog extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onConfirmDelete;

  const DeleteVehicleDialog({
    super.key,
    required this.vehicle,
    required this.onConfirmDelete,
  });

  @override
  State<DeleteVehicleDialog> createState() => _DeleteVehicleDialogState();
}

class _DeleteVehicleDialogState extends State<DeleteVehicleDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isCompleted) {
        _isCompleted = true;
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop();
        widget.onConfirmDelete();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoldStart() {
    if (_isCompleted) return;
    HapticFeedback.mediumImpact();
    _animationController.forward();
  }

  void _onHoldEnd() {
    if (_isCompleted) return;
    if (_animationController.status != AnimationStatus.completed) {
      HapticFeedback.selectionClick();
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.vehicleDeleteTitle ?? 'Usuwanie pojazdu',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              l10n?.vehicleDeletePrompt('${widget.vehicle.brand} ${widget.vehicle.model}', widget.vehicle.licensePlate) ??
                  'Czy na pewno chcesz trwale usunąć pojazd ${widget.vehicle.brand} ${widget.vehicle.model} (${widget.vehicle.licensePlate})?',
              style: const TextStyle(fontSize: 14.5, height: 1.4),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.red.shade900 : Colors.red.shade50).withValues(alpha: isDark ? 0.25 : 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isDark ? Colors.red.shade800 : Colors.red.shade200).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.vehicleDeleteWarning ??
                          'Wszystkie zarejestrowane wydatki, historia serwisowa i alerty tego auta zostaną bezpowrotnie usunięte.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Instructional label
            Center(
              child: Text(
                l10n?.vehicleDeleteHoldInstruction ?? 'Naciśnij i przytrzymaj czerwony przycisk, aby zatwierdzić',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Animated Hold-to-Delete Button
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final progress = _animationController.value;
                final isHolding = progress > 0.0;
                final remainingSec = ((1.0 - progress) * 2.5).toStringAsFixed(1);

                return GestureDetector(
                  onTapDown: (_) => _onHoldStart(),
                  onTapUp: (_) => _onHoldEnd(),
                  onTapCancel: () => _onHoldEnd(),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: isHolding ? 0.9 : 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.5),
                      child: Stack(
                        children: [
                          // Animated filling progress bar
                          FractionallySizedBox(
                            widthFactor: progress,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ),

                          // Button content
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isHolding ? Icons.timer_outlined : Icons.touch_app_rounded,
                                  size: 18,
                                  color: progress > 0.45 ? Colors.white : const Color(0xFFD32F2F),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isHolding
                                      ? (l10n?.vehicleDeleteHoldingBtn(remainingSec) ?? 'Trzymaj jeszcze ${remainingSec}s...')
                                      : (l10n?.vehicleDeleteHoldBtn ?? 'Przytrzymaj, aby usunąć'),
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: progress > 0.45 ? Colors.white : const Color(0xFFD32F2F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Cancel Button
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n?.commonCancel ?? 'Anuluj'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
