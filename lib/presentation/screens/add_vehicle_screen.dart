import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/vehicle.dart';
import '../providers/app_providers.dart';
import '../widgets/polish_license_plate.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _generationController = TextEditingController();
  final _yearController = TextEditingController(text: DateTime.now().year.toString());
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _vinController = TextEditingController();

  String _selectedFuelType = 'Benzyna';
  bool _isSaving = false;

  final List<String> _popularBrands = [
    'BMW',
    'Audi',
    'Mercedes',
    'Toyota',
    'Volkswagen',
    'Skoda',
    'Ford',
    'Volvo',
    'Kia',
    'Hyundai'
  ];

  final List<String> _fuelTypes = [
    'Benzyna',
    'Diesel',
    'Hybryda',
    'LPG',
    'Elektryczny',
  ];

  @override
  void initState() {
    super.initState();
    _brandController.addListener(() => setState(() {}));
    _modelController.addListener(() => setState(() {}));
    _generationController.addListener(() => setState(() {}));
    _licensePlateController.addListener(() => setState(() {}));
    _mileageController.addListener(() => setState(() {}));
    _yearController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _generationController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newVehicle = Vehicle(
        id: const Uuid().v4(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        generationOrTrim: _generationController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        mileageKm: int.parse(_mileageController.text.trim()),
        fuelType: _selectedFuelType,
        vin: _vinController.text.trim().toUpperCase(),
      );

      await ref.read(vehiclesNotifierProvider.notifier).addVehicle(newVehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dodano pojazd ${newVehicle.brand} ${newVehicle.model} do garażu!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd zapisu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final plate = _licensePlateController.text.trim();
    final mileageInt = int.tryParse(_mileageController.text.trim()) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Pojazd', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Live Preview Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brand.isNotEmpty || model.isNotEmpty
                                    ? '$brand $model'.trim()
                                    : 'Nowy Pojazd',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                _generationController.text.trim().isNotEmpty
                                    ? '${_generationController.text.trim()} • ${_yearController.text}'
                                    : 'Podgląd karty pojazdu',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        PolishLicensePlate(
                          plateText: plate.isNotEmpty ? plate : 'XX 00000',
                          scale: 0.9,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Rocznik: ${_yearController.text}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _selectedFuelType,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppFormatters.mileage(mileageInt),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Brand Field & Suggestion Chips
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Marka *',
                hintText: 'np. BMW, Toyota, Audi',
                prefixIcon: Icon(Icons.directions_car_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Wprowadź markę pojazdu' : null,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _popularBrands.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(b, style: const TextStyle(fontSize: 12)),
                      onPressed: () => _brandController.text = b,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Model
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model *',
                hintText: 'np. Seria 3, Corolla, Golf',
                prefixIcon: Icon(Icons.car_repair_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Wprowadź model pojazdu' : null,
            ),
            const SizedBox(height: 14),

            // Generation / Trim
            TextFormField(
              controller: _generationController,
              decoration: const InputDecoration(
                labelText: 'Generacja / Wersja wyposażenia',
                hintText: 'np. 320d xDrive (G21), 1.8 Hybrid GR Sport',
                prefixIcon: Icon(Icons.tune_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            // License Plate & Year
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _licensePlateController,
                    decoration: const InputDecoration(
                      labelText: 'Numer rej. *',
                      hintText: 'KR 7AK89',
                      prefixIcon: Icon(Icons.badge_rounded),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Wprowadź tablicę' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Rocznik *',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final y = int.tryParse(v ?? '');
                      if (y == null || y < 1900 || y > DateTime.now().year + 1) {
                        return 'Błędny rok';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Mileage
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Bieżący stan licznika *',
                hintText: 'np. 164250',
                suffixText: 'km',
                prefixIcon: Icon(Icons.speed_rounded),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => int.tryParse(v ?? '') == null ? 'Podaj stan licznika' : null,
            ),
            const SizedBox(height: 14),

            // Fuel Type Selector
            const Text(
              'Rodzaj paliwa',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _fuelTypes.map((fuel) {
                  final isSelected = _selectedFuelType == fuel;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(fuel),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedFuelType = fuel);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // VIN
            TextFormField(
              controller: _vinController,
              decoration: const InputDecoration(
                labelText: 'Numer VIN (opcjonalnie)',
                hintText: '17-znakowy numer nadwozia',
                prefixIcon: Icon(Icons.pin_rounded),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveVehicle,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Zapisz i dodaj do Garażu'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
