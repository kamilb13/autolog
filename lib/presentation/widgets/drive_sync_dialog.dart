import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class DriveSyncDialog extends ConsumerWidget {
  const DriveSyncDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driveState = ref.watch(driveSyncNotifierProvider);
    final driveNotifier = ref.read(driveSyncNotifierProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF4285F4), size: 24),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Kopia Zapasowa (Google Drive)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),

            // Account status
            if (driveState.isSignedIn) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: driveState.user?.photoUrl != null
                          ? NetworkImage(driveState.user!.photoUrl!)
                          : null,
                      child: driveState.user?.photoUrl == null
                          ? const Icon(Icons.person_rounded)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driveState.user?.displayName ?? 'Konto Google',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 14),
                          ),
                          Text(
                            driveState.user?.email ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => driveNotifier.signOut(),
                      child: const Text('Wyloguj', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 28),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Zaloguj się kontem Google, aby synchronizować bazę pojazdów w bezpiecznej chmurze.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: driveState.isSyncing ? null : () => driveNotifier.signIn(),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Zaloguj przez Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Backup & Restore Actions
            if (driveState.isSyncing) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Przetwarzanie synchronizacji z Dyskiem...'),
                    ],
                  ),
                ),
              )
            ] else ...[
              ElevatedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final res = await driveNotifier.backup();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(res.message),
                      backgroundColor: res.isSuccess ? Colors.green : Colors.red,
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('Utwórz kopię na Dysku Google'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final res = await driveNotifier.restore();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(res.message),
                      backgroundColor: res.isSuccess ? Colors.green : Colors.red,
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_download_rounded),
                label: const Text('Przywróć dane z Dysku Google'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => driveNotifier.shareLocalBackup(),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Eksportuj plik bazy (JSON / Udostępnij)'),
              ),
            ],

            if (driveState.statusMessage != null && !driveState.isSyncing) ...[
              const SizedBox(height: 10),
              Text(
                driveState.statusMessage!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
