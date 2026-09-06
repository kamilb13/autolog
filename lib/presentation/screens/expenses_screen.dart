import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/expense.dart';
import '../providers/app_providers.dart';
import '../widgets/timeline_expense_item.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesNotifierProvider);
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dziennik Wydatków',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              '${expensesState.expenses.length} wpisów • Łącznie: ${AppFormatters.currency(expensesState.totalSum)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Odśwież',
            onPressed: () => ref.read(expensesNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nowy wydatek', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Total Sum Card
          Card(
            elevation: 1.5,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SUMA WYDATKÓW',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${expensesState.expenses.length} pozycji',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.currency(expensesState.totalSum),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Szukaj wydatku, warsztatu, notatki...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(expensesNotifierProvider.notifier).setSearchQuery('');
                      },
                    )
                  : null,
            ),
            onChanged: (q) => ref.read(expensesNotifierProvider.notifier).setSearchQuery(q),
          ),
          const SizedBox(height: 12),

          // Vehicle Filter Chips
          vehiclesAsync.when(
            data: (vehicles) {
              if (vehicles.length <= 1) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          selected: expensesState.selectedVehicleId == null,
                          label: const Text('Wszystkie auta'),
                          onSelected: (_) => ref
                              .read(expensesNotifierProvider.notifier)
                              .setVehicleFilter(null),
                        ),
                      ),
                      ...vehicles.map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            selected: expensesState.selectedVehicleId == v.id,
                            label: Text('${v.brand} ${v.model}'),
                            onSelected: (_) => ref
                                .read(expensesNotifierProvider.notifier)
                                .setVehicleFilter(v.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: expensesState.selectedCategory == null,
                    showCheckmark: false,
                    label: const Text('Wszystkie kategorie'),
                    onSelected: (_) => ref
                        .read(expensesNotifierProvider.notifier)
                        .setCategoryFilter(null),
                  ),
                ),
                ...ExpenseCategory.values.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: expensesState.selectedCategory == cat,
                      showCheckmark: false,
                      avatar: Icon(
                        cat.icon,
                        size: 15,
                        color: expensesState.selectedCategory == cat ? null : cat.color,
                      ),
                      label: Text(cat.displayName),
                      onSelected: (selected) {
                        ref
                            .read(expensesNotifierProvider.notifier)
                            .setCategoryFilter(selected ? cat : null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Expenses List
          if (expensesState.expenses.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Brak pasujących wydatków',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zmień kryteria wyszukiwania lub dodaj nowy wydatek.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ...expensesState.expenses.map(
              (exp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TimelineExpenseItem(
                  expense: exp,
                  onDelete: () async {
                    final deletedExpense = exp;
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();

                    await ref.read(expensesNotifierProvider.notifier).deleteExpense(deletedExpense.id);

                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Usunięto wpis "${deletedExpense.title}"'),
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'COFNIJ',
                            textColor: Colors.black,
                            onPressed: () async {
                              await ref.read(expensesNotifierProvider.notifier).addExpense(deletedExpense);
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}
