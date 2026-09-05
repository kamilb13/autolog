import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/service_reminder.dart';
import '../../domain/models/vehicle.dart';
import '../providers/app_providers.dart';

class AddReminderDialog extends ConsumerStatefulWidget {
  final String? initialVehicleId;

  const AddReminderDialog({
    super.key,
    this.initialVehicleId,
  });

  @override
  ConsumerState<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends ConsumerState<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedVehicleId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _dueMileageController = TextEditingController();
  final _intervalMonthsController = TextEditingController();
  final _intervalKmController = TextEditingController();

  bool _isMileageBased = false;
  final AlertSeverity _severity = AlertSeverity.info;
  final AlertType _type = AlertType.generalService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  final List<String> _suggestions = [
    'Koniec polisy OC/AC',
    'Badanie techniczne',
    'Wymiana oleju i filtrów',
    'Wymiana klocków hamulcowych',
    'Wymiana paska rozrządu',
    'Serwis klimatyzacji',
    'Wymiana płynu hamulcowego',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.initialVehicleId;
    _dueDateController.text = AppFormatters.formatIsoDate(_selectedDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _dueMileageController.dispose();
    _intervalMonthsController.dispose();
    _intervalKmController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      locale: const Locale('pl', 'PL'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = AppFormatters.formatIsoDate(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz pojazd')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dueMileage = _isMileageBased && _dueMileageController.text.isNotEmpty
          ? int.tryParse(_dueMileageController.text.trim())
          : null;

      final dueDate = !_isMileageBased && _dueDateController.text.isNotEmpty
          ? _dueDateController.text.trim()
          : null;

      final intervalMonths = int.tryParse(_intervalMonthsController.text.trim());
      final intervalKm = int.tryParse(_intervalKmController.text.trim());

      final reminder = ServiceReminder(
        id: const Uuid().v4(),
        vehicleId: _selectedVehicleId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: dueDate,
        dueMileageKm: dueMileage,
        severity: _severity,
        type: _type,
        intervalMonths: intervalMonths,
        intervalKm: intervalKm,
        isCompleted: false,
      );

      await ref.read(remindersNotifierProvider.notifier).addReminder(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dodano przypomnienie: ${reminder.title}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd zapisu: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Nowy Termin / Alert',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Vehicle Dropdown
                vehiclesAsync.when(
                  data: (vehicles) {
                    if (vehicles.isEmpty) return const Text('Brak aut w garażu.');
                    if (_selectedVehicleId == null && vehicles.isNotEmpty) {
                      _selectedVehicleId = vehicles.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleId,
                      decoration: const InputDecoration(
                        labelText: 'Pojazd *',
                        prefixIcon: Icon(Icons.directions_car_rounded),
                      ),
                      items: vehicles.map((v) {
                        return DropdownMenuItem(
                          value: v.id,
                          child: Text('${v.brand} ${v.model} (${v.licensePlate})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedVehicleId = val),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Błąd: $err'),
                ),
                const SizedBox(height: 12),

                // Title & Suggestions
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tytuł przypomnienia *',
                    hintText: 'np. Badanie techniczne, Wymiana oleju',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Podaj tytuł' : null,
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _suggestions.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          onPressed: () => _titleController.text = s,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Trigger Type Selector (Date vs Mileage)
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        selected: !_isMileageBased,
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Wg Daty'),
                          ],
                        ),
                        onSelected: (val) => setState(() => _isMileageBased = !val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        selected: _isMileageBased,
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.speed_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Wg Przebiegu'),
                          ],
                        ),
                        onSelected: (val) => setState(() => _isMileageBased = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date or Mileage Input
                if (!_isMileageBased)
                  InkWell(
                    onTap: _pickDate,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _dueDateController,
                        decoration: const InputDecoration(
                          labelText: 'Data terminu *',
                          prefixIcon: Icon(Icons.calendar_month_rounded),
                        ),
                      ),
                    ),
                  )
                else
                  TextFormField(
                    controller: _dueMileageController,
                    decoration: const InputDecoration(
                      labelText: 'Limit kilometrów (cel) *',
                      hintText: 'np. 165000',
                      suffixText: 'km',
                      prefixIcon: Icon(Icons.speed_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _isMileageBased && int.tryParse(v ?? '') == null
                        ? 'Podaj limit przebiegu'
                        : null,
                  ),
                const SizedBox(height: 12),

                // Cyclic renewal intervals
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _intervalMonthsController,
                        decoration: const InputDecoration(
                          labelText: 'Cykl (miesiące)',
                          hintText: 'np. 12',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _intervalKmController,
                        decoration: const InputDecoration(
                          labelText: 'Cykl (km)',
                          hintText: 'np. 15000',
                          suffixText: 'km',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Opis / Notatka (opcjonalnie)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Buttons
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Zapisz termin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
