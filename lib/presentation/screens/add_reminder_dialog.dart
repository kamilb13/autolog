import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/service_reminder.dart';
import '../../domain/models/vehicle.dart';
import '../providers/app_providers.dart';
import '../widgets/vehicle_selector.dart';

enum MileageInputMode {
  relativeDelta, // "Za ile km od teraz" (np. za 1000 km, za 10 000 km)
  absoluteTarget, // "Dokładny stan licznika" (np. przy 175 000 km)
}

class AddReminderDialog extends ConsumerStatefulWidget {
  final String? initialVehicleId;

  const AddReminderDialog({super.key, this.initialVehicleId});

  @override
  ConsumerState<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends ConsumerState<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedVehicleId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _relativeKmController = TextEditingController(text: '15000');
  final _absoluteKmController = TextEditingController();
  final _intervalMonthsController = TextEditingController(text: '12');
  final _intervalKmController = TextEditingController(text: '15000');

  bool _isMileageBased = false;
  MileageInputMode _mileageMode = MileageInputMode.relativeDelta;
  bool _isRecurring = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  final List<String> _suggestions = [
    'Wymiana oleju i filtrów',
    'Badanie techniczne',
    'Koniec polisy OC/AC',
    'Wymiana klocków hamulcowych',
    'Wymiana płynu hamulcowego',
    'Wymiana paska rozrządu',
    'Serwis klimatyzacji',
    'Wymiana opon (sezonowa)',
    'Kontrola płynów / Docieranie',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.initialVehicleId;
    _dueDateController.text = AppFormatters.formatIsoDate(_selectedDate);

    _relativeKmController.addListener(() => setState(() {}));
    _absoluteKmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _relativeKmController.dispose();
    _absoluteKmController.dispose();
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

  void _addMonthsToDate(int months) {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month + months, now.day);
      _dueDateController.text = AppFormatters.formatIsoDate(_selectedDate);
    });
  }

  Future<void> _save(int currentVehicleMileage) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wybierz pojazd')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      int? dueMileage;
      if (_isMileageBased) {
        if (_mileageMode == MileageInputMode.relativeDelta) {
          final delta = int.tryParse(_relativeKmController.text.trim()) ?? 0;
          dueMileage = currentVehicleMileage + delta;
        } else {
          dueMileage = int.tryParse(_absoluteKmController.text.trim());
        }
      }

      final dueDate = !_isMileageBased && _dueDateController.text.isNotEmpty
          ? _dueDateController.text.trim()
          : null;

      final intervalMonths =
          _isRecurring && _intervalMonthsController.text.trim().isNotEmpty
          ? int.tryParse(_intervalMonthsController.text.trim())
          : null;

      final intervalKm =
          _isRecurring && _intervalKmController.text.trim().isNotEmpty
          ? int.tryParse(_intervalKmController.text.trim())
          : null;

      final reminder = ServiceReminder(
        id: const Uuid().v4(),
        vehicleId: _selectedVehicleId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: dueDate,
        dueMileageKm: dueMileage,
        severity: AlertSeverity.info,
        type: AlertType.generalService,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final vehicles = vehiclesAsync.valueOrNull ?? [];
    if (_selectedVehicleId == null && vehicles.isNotEmpty) {
      _selectedVehicleId = vehicles.first.id;
    }
    final selectedVehicle = vehicles
        .where((v) => v.id == _selectedVehicleId)
        .firstOrNull;
    final currentMileage = selectedVehicle?.mileageKm ?? 0;

    // Relative delta calculations
    final relativeKm = int.tryParse(_relativeKmController.text.trim()) ?? 0;
    final computedTargetMileage = currentMileage + relativeKm;

    // Absolute calculations
    final absoluteKm = int.tryParse(_absoluteKmController.text.trim());
    final computedKmRemaining = absoluteKm != null
        ? (absoluteKm - currentMileage)
        : null;

    // Date calculations
    final daysUntilDate = _selectedDate.difference(DateTime.now()).inDays + 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Nowy Termin / Alert',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
              const SizedBox(height: 12),

              // Scrollable Form Body
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle Selector
                        const Text(
                          'Pojazd',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (vehicles.isEmpty)
                          const Text('Brak aut w garażu.')
                        else
                          VehicleSelector(
                            vehicles: vehicles,
                            selectedVehicleId: _selectedVehicleId,
                            compact: true,
                            onSelected: (v) {
                              setState(() {
                                _selectedVehicleId = v.id;
                                if (_absoluteKmController.text.isNotEmpty) {
                                  _absoluteKmController.text =
                                      (v.mileageKm + 15000).toString();
                                }
                              });
                            },
                          ),
                        const SizedBox(height: 14),

                        // Title & Suggestions
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tytuł przypomnienia *',
                            hintText: 'np. Wymiana oleju, Badanie techniczne',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Podaj tytuł'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _suggestions.map((s) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ActionChip(
                                  label: Text(
                                    s,
                                    style: const TextStyle(fontSize: 11.5),
                                  ),
                                  onPressed: () {
                                    _titleController.text = s;
                                    if (s.contains('olej') ||
                                        s.contains('klock') ||
                                        s.contains('rozrząd') ||
                                        s.contains('płyn') ||
                                        s.contains('Docieranie')) {
                                      setState(() {
                                        _isMileageBased = true;
                                        if (s.contains('Docieranie')) {
                                          _relativeKmController.text = '1000';
                                          _intervalKmController.text = '1000';
                                        }
                                      });
                                    } else if (s.contains('OC') ||
                                        s.contains('Badanie') ||
                                        s.contains('opon')) {
                                      setState(() => _isMileageBased = false);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sposób wyznaczenia terminu (Data vs Przebieg)
                        const Text(
                          'Sposób wyznaczenia terminu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                selected: !_isMileageBased,
                                showCheckmark: false,
                                avatar: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                ),
                                label: const Center(child: Text('📅 Wg Daty')),
                                onSelected: (val) =>
                                    setState(() => _isMileageBased = !val),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                selected: _isMileageBased,
                                showCheckmark: false,
                                avatar: const Icon(
                                  Icons.speed_rounded,
                                  size: 16,
                                ),
                                label: const Center(
                                  child: Text('🛣️ Wg Przebiegu'),
                                ),
                                onSelected: (val) =>
                                    setState(() => _isMileageBased = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ----------------- TRYB 1: WG DATY ----------------- //
                        if (!_isMileageBased) ...[
                          InkWell(
                            onTap: _pickDate,
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _dueDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Data terminu *',
                                  prefixIcon: Icon(
                                    Icons.calendar_month_rounded,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ActionChip(
                                    label: const Text(
                                      '+1 miesiąc',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () => _addMonthsToDate(1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ActionChip(
                                    label: const Text(
                                      '+3 miesiące',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () => _addMonthsToDate(3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ActionChip(
                                    label: const Text(
                                      '+6 miesięcy',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () => _addMonthsToDate(6),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ActionChip(
                                    label: const Text(
                                      '+1 rok',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () => _addMonthsToDate(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.blue.shade900.withValues(alpha: 0.25)
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: isDark
                                      ? Colors.blue.shade300
                                      : Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    daysUntilDate > 0
                                        ? '🔔 Alert przypomni o terminie za $daysUntilDate dni (${AppFormatters.formatDisplayDate(_dueDateController.text)})'
                                        : '🔔 Wybrana data jest dzisiaj lub w przeszłości',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.blue.shade200
                                          : Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                        // ----------------- TRYB 2: WG PRZEBIEGU ----------------- //
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Aktualny stan licznika auta:',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  AppFormatters.mileage(currentMileage),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Wybór trybu przebiegu
                          Row(
                            children: [
                              Expanded(
                                child: FilterChip(
                                  selected:
                                      _mileageMode ==
                                      MileageInputMode.relativeDelta,
                                  showCheckmark: false,
                                  label: const Center(
                                    child: Text(
                                      'Za ile km od teraz',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(
                                        () => _mileageMode =
                                            MileageInputMode.relativeDelta,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilterChip(
                                  selected:
                                      _mileageMode ==
                                      MileageInputMode.absoluteTarget,
                                  showCheckmark: false,
                                  label: const Center(
                                    child: Text(
                                      'Przy stanie licznika',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _mileageMode =
                                            MileageInputMode.absoluteTarget;
                                        if (_absoluteKmController
                                            .text
                                            .isEmpty) {
                                          _absoluteKmController.text =
                                              (currentMileage + 15000)
                                                  .toString();
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (_mileageMode ==
                              MileageInputMode.relativeDelta) ...[
                            TextFormField(
                              controller: _relativeKmController,
                              decoration: const InputDecoration(
                                labelText: 'Za ile km przypomnieć? *',
                                hintText: 'np. 1000, 10000, 15000',
                                suffixText: 'km',
                                prefixIcon: Icon(Icons.add_road_rounded),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return 'Podaj dodatnią liczbę kilometrów';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    [
                                      1000,
                                      2000,
                                      5000,
                                      10000,
                                      15000,
                                      20000,
                                      60000,
                                    ].map((km) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: ActionChip(
                                          label: Text(
                                            '+${AppFormatters.mileage(km)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          onPressed: () {
                                            _relativeKmController.text = km
                                                .toString();
                                          },
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.green.shade900.withValues(
                                        alpha: 0.25,
                                      )
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 16,
                                    color: isDark
                                        ? Colors.green.shade300
                                        : Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '🔔 Alert włączy się przy liczniku: ${AppFormatters.mileage(computedTargetMileage)} (za ${AppFormatters.mileage(relativeKm)})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.green.shade200
                                            : Colors.green.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _absoluteKmController,
                              decoration: const InputDecoration(
                                labelText: 'Docelowy stan licznika *',
                                hintText: 'np. 175000',
                                suffixText: 'km',
                                prefixIcon: Icon(Icons.speed_rounded),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null) {
                                  return 'Podaj docelowy stan licznika';
                                }
                                if (n <= currentMileage) {
                                  return 'Podaj stan większy niż aktualny (${AppFormatters.mileage(currentMileage)})';
                                }
                                return null;
                              },
                            ),
                            if (computedKmRemaining != null &&
                                computedKmRemaining > 0) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.green.shade900.withValues(
                                          alpha: 0.25,
                                        )
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 16,
                                      color: isDark
                                          ? Colors.green.shade300
                                          : Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '🔔 To nastąpi za: ${AppFormatters.mileage(computedKmRemaining)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.green.shade200
                                              : Colors.green.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                        const SizedBox(height: 14),

                        // ----------------- CYKLICZNOŚĆ (POWTARZANIE) ----------------- //
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E242B)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SwitchListTile(
                                value: _isRecurring,
                                title: const Text(
                                  'Powtarzaj cyklicznie',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Automatycznie zaplanuj kolejny termin po oznaczeniu jako wykonane',
                                  style: TextStyle(fontSize: 11.5),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _isRecurring = val;
                                    if (val) {
                                      if (_relativeKmController
                                              .text
                                              .isNotEmpty &&
                                          _intervalKmController.text.isEmpty) {
                                        _intervalKmController.text =
                                            _relativeKmController.text;
                                      }
                                    }
                                  });
                                },
                              ),
                              if (_isRecurring) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),

                                      // Interwał kilometrów
                                      TextFormField(
                                        controller: _intervalKmController,
                                        decoration: const InputDecoration(
                                          labelText: 'Powtarzaj co (kilometry)',
                                          hintText: 'np. 1000, 10000, 15000',
                                          suffixText: 'km',
                                          prefixIcon: Icon(
                                            Icons.replay_rounded,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children:
                                              [
                                                1000,
                                                2000,
                                                5000,
                                                10000,
                                                15000,
                                                20000,
                                                60000,
                                              ].map((km) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 6,
                                                      ),
                                                  child: ActionChip(
                                                    label: Text(
                                                      'Co ${AppFormatters.mileage(km)}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        _intervalKmController
                                                            .text = km
                                                            .toString(),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Interwał czasowy
                                      TextFormField(
                                        controller: _intervalMonthsController,
                                        decoration: const InputDecoration(
                                          labelText: 'Powtarzaj co (miesiące)',
                                          hintText: 'np. 6, 12, 24',
                                          suffixText: 'msc',
                                          prefixIcon: Icon(
                                            Icons.event_repeat_rounded,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            ActionChip(
                                              label: const Text(
                                                'Co 6 msc',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              onPressed: () =>
                                                  _intervalMonthsController
                                                          .text =
                                                      '6',
                                            ),
                                            const SizedBox(width: 6),
                                            ActionChip(
                                              label: const Text(
                                                'Co 12 msc (1 rok)',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              onPressed: () =>
                                                  _intervalMonthsController
                                                          .text =
                                                      '12',
                                            ),
                                            const SizedBox(width: 6),
                                            ActionChip(
                                              label: const Text(
                                                'Co 24 msc (2 lata)',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              onPressed: () =>
                                                  _intervalMonthsController
                                                          .text =
                                                      '24',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Opis / Notatka (opcjonalnie)',
                            hintText: 'np. Castrol Edge 5W30, stacja kontroli pojazdów...',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fixed Action Button at bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _save(currentMileage),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Zapisz termin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
