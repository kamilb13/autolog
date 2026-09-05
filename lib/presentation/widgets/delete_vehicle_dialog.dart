import 'package:flutter/material.dart';
import '../../domain/models/vehicle.dart';

class DeleteVehicleDialog extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onConfirmDelete;

  const DeleteVehicleDialog({
    super.key,
    required this.vehicle,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          const Text('Usuń pojazd', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Czy na pewno chcesz bezpowrotnie usunąć pojazd ${vehicle.brand} ${vehicle.model} (${vehicle.licensePlate}) z garażu?',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Wszystkie powiązane wydatki i alerty serwisowe zostaną trwale usunięte.',
                    style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmDelete();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(110, 42),
          ),
          child: const Text('Usuń auto'),
        ),
      ],
    );
  }
}
