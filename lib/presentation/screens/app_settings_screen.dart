import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings.dart';

import 'package:autolog/l10n/app_localizations.dart';

import '../providers/app_providers.dart';
import '../widgets/drive_sync_dialog.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.settingsTitle ?? 'Ustawienia',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Language Section
          _buildSectionHeader(
            context,
            Icons.language_rounded,
            l10n?.settingsLanguageSection ?? 'Język aplikacji',
          ),
          _buildSettingsCard(
            context,
            isDark,
            child: Column(
              children: [
                // _buildRadioTile<AppLanguage>(
                //   title: l10n?.settingsLanguageSystem ?? 'Domyślny systemowy',
                //   subtitle: l10n?.settingsLanguageSystemSubtitle ?? 'Automatyczne dopasowanie do telefonu',
                //   value: AppLanguage.system,
                //   groupValue: settings.language,
                //   onChanged: (val) {
                //     if (val != null) ref.read(settingsNotifierProvider.notifier).setLanguage(val);
                //   },
                // ),
                // const Divider(height: 1, indent: 16, endIndent: 16),
                _buildRadioTile<AppLanguage>(
                  title: l10n?.settingsLanguagePl ?? 'Polski (PL)',
                  subtitle: l10n?.settingsLanguagePlSubtitle ?? 'Język polski',
                  value: AppLanguage.pl,
                  groupValue: settings.language,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setLanguage(val);
                    }
                  },
                ),
                // const Divider(height: 1, indent: 16, endIndent: 16),
                // _buildRadioTile<AppLanguage>(
                //   title: l10n?.settingsLanguageEn ?? 'English (EN)',
                //   subtitle: l10n?.settingsLanguageEnSubtitle ?? 'Język angielski',
                //   value: AppLanguage.en,
                //   groupValue: settings.language,
                //   onChanged: (val) {
                //     if (val != null) ref.read(settingsNotifierProvider.notifier).setLanguage(val);
                //   },
                // ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Currency Section
          _buildSectionHeader(
            context,
            Icons.payments_outlined,
            l10n?.settingsCurrencySection ?? 'Waluta',
          ),
          _buildSettingsCard(
            context,
            isDark,
            child: Column(
              children: [
                _buildRadioTile<AppCurrency>(
                  title: l10n?.settingsCurrencyPln ?? 'Polski Złoty (PLN / zł)',
                  value: AppCurrency.pln,
                  groupValue: settings.currency,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setCurrency(val);
                    }
                  },
                ),
                // const Divider(height: 1, indent: 16, endIndent: 16),
                // _buildRadioTile<AppCurrency>(
                //   title: l10n?.settingsCurrencyEur ?? 'Euro (EUR / €)',
                //   value: AppCurrency.eur,
                //   groupValue: settings.currency,
                //   onChanged: (val) {
                //     if (val != null) ref.read(settingsNotifierProvider.notifier).setCurrency(val);
                //   },
                // ),
                // const Divider(height: 1, indent: 16, endIndent: 16),
                // _buildRadioTile<AppCurrency>(
                //   title: l10n?.settingsCurrencyUsd ?? 'Dolar amerykański (USD / \$)',
                //   value: AppCurrency.usd,
                //   groupValue: settings.currency,
                //   onChanged: (val) {
                //     if (val != null) ref.read(settingsNotifierProvider.notifier).setCurrency(val);
                //   },
                // ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Distance Unit Section
          _buildSectionHeader(
            context,
            Icons.straighten_rounded,
            l10n?.settingsUnitSection ?? 'Jednostka odległości',
          ),
          _buildSettingsCard(
            context,
            isDark,
            child: Column(
              children: [
                _buildRadioTile<DistanceUnit>(
                  title: l10n?.settingsUnitKm ?? 'Kilometry (km)',
                  value: DistanceUnit.km,
                  groupValue: settings.distanceUnit,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setDistanceUnit(val);
                    }
                  },
                ),
                // const Divider(height: 1, indent: 16, endIndent: 16),
                // _buildRadioTile<DistanceUnit>(
                //   title: l10n?.settingsUnitMi ?? 'Mile (mi)',
                //   value: DistanceUnit.mi,
                //   groupValue: settings.distanceUnit,
                //   onChanged: (val) {
                //     if (val != null) ref.read(settingsNotifierProvider.notifier).setDistanceUnit(val);
                //   },
                // ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Visual Theme Section
          _buildSectionHeader(
            context,
            Icons.palette_outlined,
            l10n?.settingsThemeSection ?? 'Motyw graficzny',
          ),
          _buildSettingsCard(
            context,
            isDark,
            child: Column(
              children: [
                _buildRadioTile<ThemeMode>(
                  title: l10n?.settingsThemeSystem ?? 'Systemowy',
                  subtitle:
                      l10n?.settingsThemeSystemSubtitle ??
                      'Dopasuj do motywu telefonu',
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setThemeMode(val);
                    }
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildRadioTile<ThemeMode>(
                  title: l10n?.settingsThemeLight ?? 'Jasny',
                  subtitle:
                      l10n?.settingsThemeLightSubtitle ??
                      'Jasny motyw interfejsu',
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setThemeMode(val);
                    }
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildRadioTile<ThemeMode>(
                  title: l10n?.settingsThemeDark ?? 'Ciemny',
                  subtitle:
                      l10n?.settingsThemeDarkSubtitle ??
                      'Ciemny motyw (oszczędza baterię)',
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setThemeMode(val);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Backup Section
          _buildSectionHeader(
            context,
            Icons.backup_outlined,
            l10n?.settingsBackupSection ?? 'Kopia zapasowa i dane',
          ),
          _buildSettingsCard(
            context,
            isDark,
            child: ListTile(
              leading: Icon(
                Icons.cloud_sync_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                l10n?.settingsBackupDialogBtn ?? 'Zarządzaj kopią zapasową',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                l10n?.settingsBackupSubtitle ??
                    'Eksportuj lub importuj bazę danych (JSON)',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const DriveSyncDialog(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 6. About Section
          _buildSectionHeader(
            context,
            Icons.info_outline_rounded,
            l10n?.settingsAboutSection ?? 'O aplikacji',
          ),
          _buildSettingsCard(
            context,
            isDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AutoLog',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${l10n?.settingsVersion ?? "Wersja"} 1.0.0 (Build 1)',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.settingsAppDesc ??
                        'Lokalny, dziennik serwisowy i kosztów pojazdów.',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    bool isDark, {
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: isDark
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: child,
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    String? subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    );
  }
}
