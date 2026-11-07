import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:autolog/l10n/app_localizations.dart';

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
  final _yearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _vinController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  String _selectedFuelType = 'Benzyna';
  bool _isSaving = false;

  final List<String> _popularBrands = [
    'BMW',
    'Audi',
    'Mercedes-Benz',
    'Toyota',
    'Volkswagen',
    'Skoda',
    'Ford',
    'Volvo',
    'Kia',
    'Hyundai',
    'Opel',
    'Peugeot',
    'Renault',
    'Honda',
    'Mazda',
    'Seat',
    'Cupra',
    'Alfa Romeo',
    'Porsche',
    'Lexus',
  ];

  static const Map<String, List<String>> _popularModelsByBrand = {
    'BMW': ['Seria 3', 'Seria 5', 'Seria 1', 'X3', 'X5', 'Seria 4', 'X1'],
    'Audi': ['A4', 'A6', 'A3', 'Q5', 'Q7', 'A5', 'Q3'],
    'Mercedes-Benz': ['Klasa C', 'Klasa E', 'Klasa A', 'GLC', 'GLE', 'CLA'],
    'Toyota': ['Corolla', 'Yaris', 'RAV4', 'C-HR', 'Avensis', 'Camry', 'Auris'],
    'Volkswagen': [
      'Golf',
      'Passat',
      'Tiguan',
      'Polo',
      'Arteon',
      'Touran',
      'T-Roc',
    ],
    'Skoda': ['Octavia', 'Superb', 'Fabia', 'Kodiaq', 'Karoq', 'Scala'],
    'Ford': ['Focus', 'Mondeo', 'Fiesta', 'Kuga', 'Puma', 'Mustang'],
    'Volvo': ['XC60', 'V60', 'XC90', 'V40', 'S60', 'XC40'],
    'Kia': ['Ceed', 'Sportage', 'Rio', 'Optima', 'Stinger', 'Niro', 'Xceed'],
    'Hyundai': ['i30', 'Tucson', 'i20', 'i40', 'Kona', 'Santa Fe'],
    'Opel': ['Astra', 'Insignia', 'Corsa', 'Mokka', 'Zafira', 'Grandland'],
    'Peugeot': ['208', '308', '3008', '508', '2008', '5008'],
    'Renault': ['Megane', 'Clio', 'Laguna', 'Talisman', 'Kadjar', 'Captur'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'HR-V', 'Jazz'],
    'Mazda': ['3', '6', 'CX-5', 'CX-3', 'CX-30', 'MX-5'],
    'Seat': ['Leon', 'Ibiza', 'Ateca', 'Tarraco', 'Alhambra'],
    'Cupra': ['Formentor', 'Leon', 'Ateca', 'Born'],
    'Alfa Romeo': ['Giulia', 'Stelvio', 'Giulietta', '159', 'Tonale'],
    'Porsche': ['911', 'Cayenne', 'Panamera', 'Macan', 'Taycan'],
    'Lexus': ['IS', 'ES', 'RX', 'NX', 'GS', 'UX'],
  };

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
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final purchasePrice = _purchasePriceController.text.trim().isNotEmpty
          ? double.tryParse(
              _purchasePriceController.text.trim().replaceAll(',', '.'),
            )
          : null;

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
        purchasePricePln: purchasePrice,
      );

      await ref.read(vehiclesNotifierProvider.notifier).addVehicle(newVehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dodano pojazd ${newVehicle.brand} ${newVehicle.model} do garażu!',
            ),
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
    final l10n = AppLocalizations.of(context);
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final plate = _licensePlateController.text.trim();
    final mileageInt = int.tryParse(_mileageController.text.trim()) ?? 0;

    final brandQuery = brand.toLowerCase();
    final filteredBrands = brandQuery.isEmpty
        ? _popularBrands
        : _popularBrands
              .where((b) => b.toLowerCase().contains(brandQuery))
              .toList();

    final matchedBrandKey = _popularModelsByBrand.keys.firstWhere(
      (k) =>
          k.toLowerCase() == brandQuery ||
          (brandQuery.isNotEmpty && brandQuery.contains(k.toLowerCase())),
      orElse: () => '',
    );
    final availableModels = matchedBrandKey.isNotEmpty
        ? (_popularModelsByBrand[matchedBrandKey] ?? [])
        : <String>[];
    final modelQuery = model.toLowerCase();
    final filteredModels = modelQuery.isEmpty
        ? availableModels
        : availableModels
              .where((m) => m.toLowerCase().contains(modelQuery))
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.vehicleAddTitle ?? 'Dodaj Pojazd',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Live Preview Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
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
                                    : (l10n?.garageAddFirstVehicle ??
                                          'Nowy Pojazd'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                _generationController.text.trim().isNotEmpty
                                    ? '${_generationController.text.trim()} • ${_yearController.text}'
                                    : 'Podgląd karty pojazdu',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${l10n?.vehicleYear ?? "Rocznik"}: ${_yearController.text}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _selectedFuelType,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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

            // Brand Field & Filtered Suggestion Chips
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: '${l10n?.vehicleBrand ?? "Marka"} *',
                hintText: 'np. BMW, Toyota, Audi, Volkswagen',
                prefixIcon: const Icon(Icons.directions_car_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Wprowadź markę pojazdu'
                  : null,
            ),
            if (filteredBrands.isNotEmpty) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filteredBrands.map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(b, style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          _brandController.text = b;
                          _brandController.selection =
                              TextSelection.fromPosition(
                                TextPosition(offset: b.length),
                              );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Model & Filtered Suggestion Chips
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: '${l10n?.vehicleModel ?? "Model"} *',
                hintText: 'np. Seria 3, Corolla, Golf',
                prefixIcon: const Icon(Icons.car_repair_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Wprowadź model pojazdu'
                  : null,
            ),
            if (filteredModels.isNotEmpty) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filteredModels.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(m, style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          _modelController.text = m;
                          _modelController.selection =
                              TextSelection.fromPosition(
                                TextPosition(offset: m.length),
                              );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Generation / Trim
            TextFormField(
              controller: _generationController,
              decoration: InputDecoration(
                labelText:
                    l10n?.vehicleGeneration ?? 'Generacja / Wersja wyposażenia',
                hintText: 'np. 320d xDrive (G21), 1.8 Hybrid GR Sport',
                prefixIcon: const Icon(Icons.tune_rounded),
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
                    decoration: InputDecoration(
                      labelText: '${l10n?.vehiclePlate ?? "Numer rej."} *',
                      hintText: 'KR 7AK89',
                      prefixIcon: const Icon(Icons.badge_rounded),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Wprowadź tablicę'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      labelText: '${l10n?.vehicleYear ?? "Rocznik"} *',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final y = int.tryParse(v ?? '');
                      if (y == null ||
                          y < 1900 ||
                          y > DateTime.now().year + 1) {
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
              decoration: InputDecoration(
                labelText:
                    '${l10n?.garageCurrentMileage ?? "Bieżący stan licznika"} *',
                hintText: 'np. 164250',
                suffixText: 'km',
                prefixIcon: const Icon(Icons.speed_rounded),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Podaj stan licznika' : null,
            ),
            const SizedBox(height: 14),

            // Fuel Type Selector
            Text(
              l10n?.vehicleFuel ?? 'Rodzaj paliwa',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
              decoration: InputDecoration(
                labelText: l10n?.vehicleVin ?? 'Numer VIN (opcjonalnie)',
                hintText: '17-znakowy numer nadwozia',
                prefixIcon: const Icon(Icons.pin_rounded),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 14),

            // Purchase Price
            TextFormField(
              controller: _purchasePriceController,
              decoration: InputDecoration(
                labelText:
                    l10n?.vehiclePurchasePrice ??
                    'Cena zakupu auta (opcjonalnie)',
                hintText: 'np. 85000',
                suffixText: 'PLN',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveVehicle,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(l10n?.commonSave ?? 'Zapisz i dodaj do Garażu'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
