import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/formatters.dart';

class UpdateMileageDialog extends StatefulWidget {
  final int currentMileageKm;
  final Function(int newMileage) onConfirm;

  const UpdateMileageDialog({
    super.key,
    required this.currentMileageKm,
    required this.onConfirm,
  });

  @override
  State<UpdateMileageDialog> createState() => _UpdateMileageDialogState();
}

class _UpdateMileageDialogState extends State<UpdateMileageDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentMileageKm.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 0) {
      setState(() => _errorText = 'Wprowadź prawidłowy przebieg');
      return;
    }
    widget.onConfirm(value);
    Navigator.of(context).pop();
  }

  void _addKm(int km) {
    final current = int.tryParse(_controller.text.trim()) ?? widget.currentMileageKm;
    _controller.text = (current + km).toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.speed_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Aktualizuj przebieg', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Obecny stan: ${AppFormatters.mileage(widget.currentMileageKm)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Nowy stan licznika',
              suffixText: 'km',
              errorText: _errorText,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('+100 km'),
                onPressed: () => _addKm(100),
              ),
              ActionChip(
                label: const Text('+500 km'),
                onPressed: () => _addKm(500),
              ),
              ActionChip(
                label: const Text('+1000 km'),
                onPressed: () => _addKm(1000),
              ),
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 42),
          ),
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}
