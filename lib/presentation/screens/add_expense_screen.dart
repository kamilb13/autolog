import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/formatters.dart';
import '../../data/services/expense_suggestions_service.dart';
import '../../data/services/receipt_ocr_service.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/expense_suggestion.dart';

import 'package:autolog/l10n/app_localizations.dart';

import '../providers/app_providers.dart';
import '../widgets/vehicle_selector.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? initialVehicleId;
  final Expense? initialExpense;

  const AddExpenseScreen({
    super.key,
    this.initialVehicleId,
    this.initialExpense,
  });

  bool get isEditing => initialExpense != null;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedVehicleId;
  ExpenseCategory _selectedCategory = ExpenseCategory.fuel;
  bool _userManuallyChangedCategory = false;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController(
    text: AppFormatters.formatDate(DateTime.now()),
  );
  final _mileageController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isScanningReceipt = false;
  ParsedReceiptData? _lastScanResult;

  @override
  void initState() {
    super.initState();
    final editExp = widget.initialExpense;
    if (editExp != null) {
      _selectedVehicleId = editExp.vehicleId;
      _selectedCategory = editExp.category;
      _userManuallyChangedCategory = true;
      _titleController.text = editExp.title;
      _amountController.text = editExp.amountPln % 1 == 0
          ? editExp.amountPln.toInt().toString()
          : editExp.amountPln.toStringAsFixed(2);
      _selectedDate = DateTime.tryParse(editExp.date) ?? DateTime.now();
      _dateController.text = AppFormatters.formatDate(_selectedDate);
      _mileageController.text = editExp.mileageKm != null
          ? editExp.mileageKm.toString()
          : '';
      _locationController.text = editExp.workshopOrLocation ?? '';
      _noteController.text = editExp.note ?? '';
    } else {
      _selectedVehicleId = widget.initialVehicleId;
    }
    _titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _applySuggestion(ExpenseSuggestion suggestion) {
    setState(() {
      _titleController.text = suggestion.title;
      _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: suggestion.title.length),
      );
      _selectedCategory = suggestion.category;
      _userManuallyChangedCategory = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = AppFormatters.formatDate(picked);
      });
      _formKey.currentState?.validate();
    }
  }

  Future<void> _showOcrPickerSheet() async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.document_scanner_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n?.ocrScanReceipt ?? 'Zeskanuj paragon / fakturę',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: Text(l10n?.ocrSourceCamera ?? 'Zrób zdjęcie aparatem'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _processReceiptOcr(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text(l10n?.ocrSourceGallery ?? 'Wybierz z galerii'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _processReceiptOcr(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processReceiptOcr(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isScanningReceipt = true);

    try {
      final ocrService = ref.read(receiptOcrServiceProvider);
      final result = await ocrService.pickAndScan(source: source);

      if (!mounted) return;

      if (result != null && result.hasAnyData) {
        setState(() {
          _lastScanResult = result;

          if (result.amount != null) {
            _amountController.text = (result.amount! % 1 == 0
                ? result.amount!.toInt().toString()
                : result.amount!.toStringAsFixed(2));
          }

          if (result.date != null) {
            _selectedDate = result.date!;
            _dateController.text = AppFormatters.formatDate(result.date!);
          }

          if (result.location != null && result.location!.isNotEmpty) {
            _locationController.text = result.location!;
          }

          if (result.suggestedTitle != null &&
              result.suggestedTitle!.isNotEmpty) {
            _titleController.text = result.suggestedTitle!;
          }

          _selectedCategory = result.suggestedCategory;
          _userManuallyChangedCategory = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.ocrSuccessBanner ??
                  'Odczytano dane z paragonu. Zweryfikuj i zatwierdź.',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.ocrNoDataFound ??
                  'Nie udało się odczytać kwoty ani daty ze zdjęcia.',
            ),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd skanera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanningReceipt = false);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wybierz pojazd')));
      return;
    }

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);

    try {
      final amount = double.parse(
        _amountController.text.trim().replaceAll(',', '.'),
      );
      final mileage = _mileageController.text.trim().isNotEmpty
          ? int.tryParse(_mileageController.text.trim())
          : null;

      final dateString = AppFormatters.formatIsoDate(_selectedDate);

      if (widget.initialExpense != null) {
        final updatedExpense = widget.initialExpense!.copyWith(
          vehicleId: _selectedVehicleId!,
          category: _selectedCategory,
          title: _titleController.text.trim(),
          amountPln: amount,
          date: dateString,
          mileageKm: mileage,
          clearMileage: mileage == null,
          workshopOrLocation: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

        await ref
            .read(expensesNotifierProvider.notifier)
            .updateExpense(updatedExpense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.expenseUpdatedMsg ?? 'Zaktualizowano wydatek!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        final newExpense = Expense(
          id: const Uuid().v4(),
          vehicleId: _selectedVehicleId!,
          category: _selectedCategory,
          title: _titleController.text.trim(),
          amountPln: amount,
          date: dateString,
          mileageKm: mileage,
          workshopOrLocation: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

        await ref
            .read(expensesNotifierProvider.notifier)
            .addExpense(newExpense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.expenseSavedMsg ??
                    'Zapisano wydatek "${newExpense.title}"!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
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
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final vehicles = vehiclesAsync.valueOrNull ?? [];
    final selectedVehicle = vehicles
        .where((v) => v.id == _selectedVehicleId)
        .firstOrNull;
    final learnedSuggestionsAsync = ref.watch(expenseSuggestionsProvider);
    final learnedSuggestions = learnedSuggestionsAsync.valueOrNull ?? [];
    final settings = ref.watch(settingsNotifierProvider);
    final l10n = AppLocalizations.of(context);

    final query = _titleController.text.trim();
    final suggestions = ExpenseSuggestionsService.getSuggestions(
      query: query,
      categoryFilter: query.isEmpty ? _selectedCategory : null,
      userSuggestions: learnedSuggestions,
      limit: 10,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? (l10n?.editExpenseTitle ?? 'Edytuj wydatek')
              : (l10n?.addExpenseTitle ?? 'Nowy wydatek'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isScanningReceipt
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.crop_free_rounded, size: 26),
            tooltip:
                l10n?.ocrScanReceiptTooltip ??
                'Zeskanuj paragon lub fakturę aparatem',
            onPressed: _isScanningReceipt ? null : _showOcrPickerSheet,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveExpense,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.isEditing
                          ? (l10n?.editExpenseSaveBtn ?? 'Zapisz zmiany')
                          : (l10n?.addExpenseSaveBtn ?? 'Zapisz wydatek'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // OCR Extraction Result Banner
            if (_lastScanResult != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n?.ocrSuccessBanner ?? 'Odczytano dane z paragonu. Zweryfikuj i zatwierdź.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _lastScanResult = null),
                    ),
                  ],
                ),
              ),
            ],

            // Vehicle Selector
            vehiclesAsync.when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return const Text(
                    'Brak pojazdów w garażu. Dodaj auto przed dodaniem wydatku.',
                  );
                }

                if (_selectedVehicleId == null && vehicles.isNotEmpty) {
                  _selectedVehicleId = vehicles.first.id;
                }

                return VehicleSelector(
                  compact: true,
                  vehicles: widget.initialVehicleId != null
                      ? vehicles
                            .where((v) => v.id == widget.initialVehicleId)
                            .toList()
                      : vehicles,
                  selectedVehicleId: _selectedVehicleId,
                  onSelected: (v) {
                    setState(() {
                      _selectedVehicleId = v.id;
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Błąd: $err'),
            ),
            const SizedBox(height: 10),

            // Category Selector Chips
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
                      avatar: Icon(
                        cat.icon,
                        size: 16,
                        color: isSelected ? Colors.white : cat.color,
                      ),
                      label: Text(
                        cat.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selectedColor: cat.color,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                            _userManuallyChangedCategory = true;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Kwota *',
                hintText: '0.00',
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Podaj kwotę';
                final normalized = v.replaceAll(',', '.');
                final num = double.tryParse(normalized);
                if (num == null || num <= 0) {
                  return 'Wprowadź prawidłową kwotę większą od zera';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Title / Description Field (with Auto-categorization listener)
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł / Usługa *',
                hintText: 'np. Tankowanie, Wymiana oleju, Wycieraczki...',
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (text) {
                if (!_userManuallyChangedCategory) {
                  final detectedCat = ExpenseSuggestionsService.inferCategory(
                    text,
                  );
                  if (detectedCat != null && detectedCat != _selectedCategory) {
                    setState(() => _selectedCategory = detectedCat);
                  }
                }
              },
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Podaj tytuł wydatku' : null,
            ),

            // Autocomplete / Suggestions chips bar
            if (suggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: suggestions.map((sug) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: Icon(
                            sug.category.icon,
                            size: 14,
                            color: sug.category.color,
                          ),
                          label: Text(
                            sug.title,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _applySuggestion(sug),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 10),

            // Date & Mileage
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(labelText: 'Data *'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mileageController,
                    decoration: InputDecoration(
                      labelText: 'Przebieg (opc.)',
                      hintText: selectedVehicle != null
                          ? 'np. ${selectedVehicle.mileageKm}'
                          : null,
                      suffixText: settings.distanceUnit.label,
                      helperText: selectedVehicle != null
                          ? () {
                              final now = DateTime.now();
                              final today = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              final expenseDateOnly = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                              );
                              final isHistorical = expenseDateOnly.isBefore(
                                today,
                              );

                              if (isHistorical) {
                                return 'Wpis wsteczny (opcjonalny przebieg)';
                              } else {
                                return 'Aktualny licznik: ${AppFormatters.mileage(selectedVehicle.mileageKm, unit: settings.distanceUnit.label)}';
                              }
                            }()
                          : 'Opcjonalnie',
                      helperMaxLines: 2,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return null; // Opcjonalne!
                      }
                      final km = int.tryParse(v.trim());
                      if (km == null || km < 0) return 'Nieprawidłowy przebieg';

                      if (selectedVehicle != null) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final expenseDateOnly = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                        );
                        final isHistorical = expenseDateOnly.isBefore(today);

                        if (!isHistorical && km < selectedVehicle.mileageKm) {
                          return 'Min. ${AppFormatters.mileage(selectedVehicle.mileageKm, unit: settings.distanceUnit.label)} (aktualny stan)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Workshop / Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokalizacja / Warsztat (opcjonalnie)',
                hintText: 'np. Orlen, Bimmer Serwis, Allegro',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notatka (opcjonalnie)',
                hintText:
                    'Dodatkowe informacje, numery części, ilość litrów...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
