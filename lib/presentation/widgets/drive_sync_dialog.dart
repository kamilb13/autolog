import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autolog/l10n/app_localizations.dart';

import '../providers/app_providers.dart';

class DriveSyncDialog extends ConsumerWidget {
  const DriveSyncDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driveState = ref.watch(driveSyncNotifierProvider);
    final driveNotifier = ref.read(driveSyncNotifierProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.backup_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.backupDialogTitle ?? 'Kopia Zapasowa',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n?.backupDialogSubtitle ?? 'Lokalny plik JSON',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Loading Indicator
            if (driveState.isSyncing) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.backupProcessing ??
                            'Przetwarzanie operacji na pliku bazy danych...',
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Action 1: Export & Share Backup
              ElevatedButton.icon(
                onPressed: () async {
                  await driveNotifier.shareLocalBackup();
                },
                icon: const Icon(Icons.file_upload_rounded),
                label: Text(l10n?.backupExportBtn ?? 'Eksportuj kopię bazy'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Action 2: Import & Restore Backup
              OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final res = await driveNotifier.importLocalBackup();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(res.message),
                      backgroundColor: res.isSuccess
                          ? Colors.green
                          : Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  if (res.isSuccess && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.file_download_rounded),
                label: Text(
                  l10n?.backupImportBtn ?? 'Importuj i przywróć bazę',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 12),

            // Notice about Local JSON Backup
            Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.backupLocalNotice ?? 'Twoje dane są zapisane lokalnie w telefonie. Przed odinstalowaniem aplikacji lub zmianą telefonu wyeksportuj plik JSON i zapisz go na dysku lub wyślij mailem.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
