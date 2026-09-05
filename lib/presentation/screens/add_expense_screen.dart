import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/expense.dart';
import '../providers/app_providers.dart';
import '../widgets/vehicle_selector.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? initialVehicleId;

  const AddExpenseScreen({
    super.key,
    this.initialVehicleId,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedVehicleId;
  ExpenseCategory _selectedCategory = ExpenseCategory.fuel;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController(
    text: AppFormatters.formatIsoDate(DateTime.now()),
  );
  final _mileageController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final Map<ExpenseCategory, List<String>> _categorySuggestions = {
    ExpenseCategory.fuel: ['Tankowanie Pb95', 'Tankowanie Diesel', 'Tankowanie LPG', 'AdBlue'],
    ExpenseCategory.service: [
      'Wymiana oleju i filtrów',
      'Klocki i tarcze hamulcowe',
      'Geometria zawieszenia',
      'Serwis klimatyzacji',
      'Wymiana rozrządu'
    ],
    ExpenseCategory.parts: ['Wycieraczki szyb', 'Płyn do spryskiwaczy', 'Akumulator', 'Żarówki / Oświetlenie'],
    ExpenseCategory.insurance: ['Polisa OC', 'Pakiet OC + AC + NNW', 'Assistance'],
    ExpenseCategory.tollsFees: ['Autostrada A4', 'Myjnia detailingowa', 'Badanie techniczne', 'Parkometr'],
  };

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.initialVehicleId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pl', 'PL'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = AppFormatters.formatIsoDate(picked);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz pojazd')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text.trim().replaceAll(',', '.'));
      final mileage = int.parse(_mileageController.text.trim());

      final newExpense = Expense(
        id: const Uuid().v4(),
        vehicleId: _selectedVehicleId!,
        category: _selectedCategory,
        title: _titleController.text.trim(),
        amountPln: amount,
        date: _dateController.text.trim(),
        mileageKm: mileage,
        workshopOrLocation: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );

      await ref.read(expensesNotifierProvider.notifier).addExpense(newExpense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zapisano wydatek "${newExpense.title}"!'),
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
    final suggestions = _categorySuggestions[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowy Wydatek', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Vehicle Selector
            const Text(
              'Pojazd',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            vehiclesAsync.when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return const Text('Brak pojazdów w garażu. Dodaj auto przed dodaniem wydatku.');
                }

                if (_selectedVehicleId == null && vehicles.isNotEmpty) {
                  _selectedVehicleId = vehicles.first.id;
                  if (_mileageController.text.isEmpty) {
                    _mileageController.text = vehicles.first.mileageKm.toString();
                  }
                } else if (_selectedVehicleId != null && _mileageController.text.isEmpty) {
                  final v = vehicles.where((element) => element.id == _selectedVehicleId).firstOrNull;
                  if (v != null) {
                    _mileageController.text = v.mileageKm.toString();
                  }
                }

                return VehicleSelector(
                  vehicles: vehicles,
                  selectedVehicleId: _selectedVehicleId,
                  onSelected: (v) {
                    setState(() {
                      _selectedVehicleId = v.id;
                      _mileageController.text = v.mileageKm.toString();
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Błąd: $err'),
            ),
            const SizedBox(height: 14),

            // Category Selector Chips
            const Text(
              'Kategoria wydatku',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(cat.icon, size: 16, color: isSelected ? null : cat.color),
                      label: Text(cat.displayName),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Kwota *',
                hintText: 'np. 350.00',
                suffixText: 'PLN',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Podaj kwotę';
                final n = double.tryParse(v.trim().replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Nieprawidłowa kwota';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Title & Suggestions
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł / Nazwa wpisu *',
                hintText: 'np. Tankowanie Pb95, Serwis olejowy',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => v == null || v.trim().isEmpty ? 'Podaj tytuł wydatku' : null,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: suggestions.map((sug) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(sug, style: const TextStyle(fontSize: 12)),
                      onPressed: () => _titleController.text = sug,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Date & Mileage
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Data *',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mileageController,
                    decoration: InputDecoration(
                      labelText: _selectedCategory == ExpenseCategory.fuel
                          ? 'Stan licznika *'
                          : 'Przebieg *',
                      suffixText: 'km',
                      prefixIcon: const Icon(Icons.speed_rounded),
                      helperText: _selectedCategory == ExpenseCategory.fuel
                          ? 'Wymagany do statystyk'
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return _selectedCategory == ExpenseCategory.fuel
                            ? 'Wymagany stan licznika'
                            : 'Podaj przebieg';
                      }
                      final km = int.tryParse(v.trim());
                      if (km == null || km < 0) return 'Nieprawidłowy przebieg';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Workshop / Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokalizacja / Warsztat (opcjonalnie)',
                hintText: 'np. Orlen, Bimmer Serwis, Allegro',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notatka (opcjonalnie)',
                hintText: 'Dodatkowe informacje, numery części, ilość litrów...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveExpense,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Zapisz wydatek'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
