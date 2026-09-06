import 'dart:math' as math;
import 'package:flutter/material.dart';

class PolishLicensePlate extends StatelessWidget {
  final String plateText;
  final double scale;
  final VoidCallback? onTap;

  const PolishLicensePlate({
    super.key,
    required this.plateText,
    this.scale = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format plate text with space between district code and registration characters if needed
    final cleanText = plateText.trim().toUpperCase();

    final plateWidget = Container(
      height: 32 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5 * scale),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 1.6 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 3 * scale,
            offset: Offset(0, 1.5 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.4 * scale),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Authentic EU Blue Euroband
            Container(
              width: 22 * scale,
              color: const Color(0xFF003399),
              padding: EdgeInsets.symmetric(vertical: 2 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // EU 12-star circle emulation
                  SizedBox(
                    width: 12 * scale,
                    height: 12 * scale,
                    child: CustomPaint(
                      painter: _EuStarsPainter(color: const Color(0xFFFFCC00)),
                    ),
                  ),
                  // White Polish country code
                  Text(
                    'PL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5 * scale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5 * scale,
                      height: 1.0,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ],
              ),
            ),

            // Embossed License Plate Characters
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 9 * scale),
              child: Text(
                cleanText,
                style: TextStyle(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w900,
                  fontSize: 16 * scale,
                  letterSpacing: 1.6 * scale,
                  height: 1.0,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5 * scale),
          child: plateWidget,
        ),
      );
    }

    return plateWidget;
  }
}

class _EuStarsPainter extends CustomPainter {
  final Color color;

  _EuStarsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;
    const count = 12;

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), size.width * 0.08, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
