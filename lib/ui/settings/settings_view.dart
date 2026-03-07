import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../tags/manage_tags_page.dart';
import 'backup_restore_page.dart';
import 'privacy_mode_page.dart';
import '../settings/settings_view_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) {
          final privacyMode = viewModel.settings.privacyModeEnabled;

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_off),
                title: const Text('Privacy Mode'),
                subtitle: Text(privacyMode ? 'Enabled' : 'Disabled'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyModePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: Text(l10n.tags),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageTagsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                subtitle: const Text('Backup and restore your data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BackupRestorePage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
