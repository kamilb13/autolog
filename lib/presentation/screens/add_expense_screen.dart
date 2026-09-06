import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/formatters.dart';
import '../../data/services/expense_suggestions_service.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/expense_suggestion.dart';
import 'package:autolog/l10n/app_localizations.dart';
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
  bool _userManuallyChangedCategory = false;

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

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.initialVehicleId;
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
    final learnedSuggestionsAsync = ref.watch(expenseSuggestionsProvider);
    final learnedSuggestions = learnedSuggestionsAsync.valueOrNull ?? [];
    final settings = ref.watch(settingsNotifierProvider);
    final theme = Theme.of(context);
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
        title: Text(l10n?.addExpenseTitle ?? 'Nowy Wydatek', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            Row(
              children: [
                const Text(
                  'Kategoria wydatku',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _selectedCategory.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_selectedCategory.icon, size: 12, color: _selectedCategory.color),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCategory.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _selectedCategory.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            const SizedBox(height: 14),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n?.addExpenseAmount != null ? '${l10n?.addExpenseAmount} *' : 'Kwota *',
                hintText: 'np. 350.00',
                suffixText: settings.currency.symbol,
                prefixIcon: const Icon(Icons.payments_rounded),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n?.addExpenseInvalidAmount ?? 'Podaj kwotę';
                final n = double.tryParse(v.trim().replaceAll(',', '.'));
                if (n == null || n <= 0) return l10n?.addExpenseInvalidAmount ?? 'Nieprawidłowa kwota';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Title & Suggestions
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tytuł / Nazwa wpisu *',
                hintText: 'np. Tankowanie Pb95, Wycieraczki szyb, Wymiana oleju',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        tooltip: 'Wyczyść pole',
                        onPressed: () {
                          _titleController.clear();
                          setState(() {
                            _userManuallyChangedCategory = false;
                          });
                        },
                      )
                    : null,
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (text) {
                if (!_userManuallyChangedCategory) {
                  final inferred = ExpenseSuggestionsService.inferCategory(
                    text,
                    customSuggestions: learnedSuggestions,
                  );
                  if (inferred != null && inferred != _selectedCategory) {
                    setState(() {
                      _selectedCategory = inferred;
                    });
                  }
                }
              },
              validator: (v) => v == null || v.trim().isEmpty ? 'Podaj tytuł wydatku' : null,
            ),
            const SizedBox(height: 8),

            // Suggestion Chips / Autocomplete Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  query.isEmpty
                      ? 'Popularne w kategorii (${suggestions.length}):'
                      : 'Podpowiedzi (${suggestions.length}):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (query.isNotEmpty)
                  Text(
                    'Wybór ustawi kategorię',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Brak pasujących podpowiedzi. Nowy wpis zostanie zapamiętany w historii.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: suggestions.map((sug) {
                    final isDifferentCategory = sug.category != _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        avatar: Icon(
                          sug.category.icon,
                          size: 14.5,
                          color: sug.category.color,
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(sug.title, style: const TextStyle(fontSize: 12)),
                            if (sug.isCustom) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.history_rounded, size: 12, color: Colors.grey.shade600),
                            ],
                          ],
                        ),
                        backgroundColor: isDifferentCategory
                            ? sug.category.color.withValues(alpha: 0.08)
                            : null,
                        side: isDifferentCategory
                            ? BorderSide(color: sug.category.color.withValues(alpha: 0.35))
                            : null,
                        tooltip: 'Kategoria: ${sug.category.displayName}${sug.isCustom ? ' (z Twojej historii)' : ''}',
                        onPressed: () => _applySuggestion(sug),
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
                      suffixText: settings.distanceUnit.label,
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
