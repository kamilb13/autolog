import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autolog/l10n/app_localizations.dart';

import '../providers/app_providers.dart';
import 'app_settings_screen.dart';
import 'expenses_screen.dart';
import 'garage_screen.dart';
import 'reminders_screen.dart';
import 'stats_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remindersState = ref.watch(remindersNotifierProvider);
    final urgentCount = remindersState.urgentCount;
    final l10n = AppLocalizations.of(context);

    final screens = [
      GarageScreen(onNavigateToReminders: () => _navigateToTab(2)),
      const ExpensesScreen(),
      const RemindersScreen(),
      const StatsScreen(),
      const AppSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.directions_car_outlined),
            selectedIcon: const Icon(Icons.directions_car_rounded),
            label: l10n?.navGarage ?? 'Garaż',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n?.navExpenses ?? 'Wydatki',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: urgentCount > 0,
              label: Text(urgentCount.toString()),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: urgentCount > 0,
              label: Text(urgentCount.toString()),
              child: const Icon(Icons.notifications_rounded),
            ),
            label: l10n?.navReminders ?? 'Terminy',
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics_rounded),
            label: l10n?.navStats ?? 'Statystyki',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n?.navSettings ?? 'Ustawienia',
          ),
        ],
      ),
    );
  }
}
