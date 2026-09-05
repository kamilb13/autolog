import 'package:flutter/material.dart';

class PolishLicensePlate extends StatelessWidget {
  final String plateText;
  final double scale;

  const PolishLicensePlate({
    super.key,
    required this.plateText,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        border: Border.all(color: Colors.black, width: 1.5 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue PL Euroband
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4 * scale,
              vertical: 3 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF003399),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2.5 * scale),
                bottomLeft: Radius.circular(2.5 * scale),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 6 * scale,
                  color: const Color(0xFFFFCC00),
                ),
                Text(
                  'PL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Plate text
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8 * scale,
              vertical: 2 * scale,
            ),
            child: Text(
              plateText.toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                fontSize: 14 * scale,
                letterSpacing: 1.2 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
