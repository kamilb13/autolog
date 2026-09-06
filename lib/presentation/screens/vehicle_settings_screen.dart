import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autolog/l10n/app_localizations.dart';
import '../../domain/models/vehicle.dart';
import '../providers/app_providers.dart';
import '../widgets/delete_vehicle_dialog.dart';

class VehicleSettingsScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const VehicleSettingsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  ConsumerState<VehicleSettingsScreen> createState() => _VehicleSettingsScreenState();
}

class _VehicleSettingsScreenState extends ConsumerState<VehicleSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _generationController;
  late TextEditingController _yearController;
  late TextEditingController _licensePlateController;
  late TextEditingController _mileageController;
  late TextEditingController _vinController;
  late TextEditingController _purchasePriceController;
  late String _selectedFuelType;

  bool _isSaving = false;

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
    final v = widget.vehicle;
    _brandController = TextEditingController(text: v.brand);
    _modelController = TextEditingController(text: v.model);
    _generationController = TextEditingController(text: v.generationOrTrim);
    _yearController = TextEditingController(text: v.year.toString());
    _licensePlateController = TextEditingController(text: v.licensePlate);
    _mileageController = TextEditingController(text: v.mileageKm.toString());
    _vinController = TextEditingController(text: v.vin);
    _purchasePriceController = TextEditingController(
      text: v.purchasePricePln != null
          ? (v.purchasePricePln! % 1 == 0
              ? v.purchasePricePln!.toInt().toString()
              : v.purchasePricePln!.toString())
          : '',
    );
    _selectedFuelType = v.fuelType;
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final purchasePrice = _purchasePriceController.text.trim().isNotEmpty
          ? double.tryParse(_purchasePriceController.text.trim().replaceAll(',', '.'))
          : null;

      final updated = widget.vehicle.copyWith(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        generationOrTrim: _generationController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        mileageKm: int.parse(_mileageController.text.trim()),
        fuelType: _selectedFuelType,
        vin: _vinController.text.trim().toUpperCase(),
        purchasePricePln: purchasePrice,
        clearPurchasePrice: purchasePrice == null,
      );

      await ref.read(vehiclesNotifierProvider.notifier).updateVehicle(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zapisano zmiany w pojeździe!'),
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => DeleteVehicleDialog(
        vehicle: widget.vehicle,
        onConfirmDelete: () async {
          await ref.read(vehiclesNotifierProvider.notifier).deleteVehicle(widget.vehicle.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Usunięto pojazd ${widget.vehicle.brand} ${widget.vehicle.model}'),
              ),
            );
            // Pop back to garage
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.vehicleEditTitle ?? 'Ustawienia Pojazdu', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: '${l10n?.vehicleBrand ?? "Marka"} *',
                prefixIcon: const Icon(Icons.directions_car_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Wprowadź markę' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: '${l10n?.vehicleModel ?? "Model"} *',
                prefixIcon: const Icon(Icons.car_repair_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Wprowadź model' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _generationController,
              decoration: InputDecoration(
                labelText: l10n?.vehicleGeneration ?? 'Generacja / Wersja wyposażenia',
                prefixIcon: const Icon(Icons.tune_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _licensePlateController,
                    decoration: InputDecoration(
                      labelText: '${l10n?.vehiclePlate ?? "Numer rej."} *',
                      prefixIcon: const Icon(Icons.badge_rounded),
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
                    decoration: InputDecoration(
                      labelText: '${l10n?.vehicleYear ?? "Rocznik"} *',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Błędny rok' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _mileageController,
              decoration: InputDecoration(
                labelText: '${l10n?.garageCurrentMileage ?? "Bieżący stan licznika"} *',
                suffixText: 'km',
                prefixIcon: const Icon(Icons.speed_rounded),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => int.tryParse(v ?? '') == null ? 'Podaj stan licznika' : null,
            ),
            const SizedBox(height: 14),

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

            TextFormField(
              controller: _vinController,
              decoration: InputDecoration(
                labelText: l10n?.vehicleVin ?? 'Numer VIN',
                prefixIcon: const Icon(Icons.pin_rounded),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _purchasePriceController,
              decoration: InputDecoration(
                labelText: l10n?.vehiclePurchasePrice ?? 'Cena zakupu auta (opcjonalnie)',
                hintText: 'np. 85000',
                suffixText: 'PLN',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(l10n?.commonSave ?? 'Zapisz zmiany'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Clean Vehicle Management Action
            Center(
              child: TextButton.icon(
                onPressed: _showDeleteDialog,
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                label: Text(
                  l10n?.vehicleDeleteBtn ?? 'Usuń pojazd z garażu',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
