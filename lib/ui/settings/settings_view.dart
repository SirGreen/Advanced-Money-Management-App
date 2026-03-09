import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../l10n/app_localizations.dart';
import '../tags/manage_tags_page.dart';
import 'backup_restore_page.dart';
import 'privacy_mode_page.dart';
import 'settings_view_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showApiKeyDialog(BuildContext context, SettingsViewModel viewModel) {
    final controller = TextEditingController(text: viewModel.settings.geminiApiKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Gemini API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Paste your key here',
            helperText: 'Used for AI-powered features',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.updateGeminiApiKey(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

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
              
              const Divider(),

              SwitchListTile(
                secondary: const Icon(Icons.security),
                title: const Text('App Lock (PIN & Biometrics)'),
                subtitle: Text(
                  viewModel.isAppLockEnabled ? 'Enabled' : 'Disabled',
                ),
                value: viewModel.isAppLockEnabled,
                onChanged: (bool value) async {
                  if (value) {
                    final auth = LocalAuthentication();
                    final canAuthenticate =
                        await auth.canCheckBiometrics ||
                        await auth.isDeviceSupported();

                    if (!canAuthenticate) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your device does not support passcode or biometrics.',
                            ),
                          ),
                        );
                      }
                      return;
                    }

                    bool didAuthenticate = false;
                    try {
                      didAuthenticate = await auth.authenticate(
                        localizedReason: 'Authenticate to enable App Lock',
                        authMessages: const <AuthMessages>[
                          AndroidAuthMessages(
                            signInTitle: 'Enable App Lock',
                            cancelButton: 'Cancel',
                          ),
                          IOSAuthMessages(cancelButton: 'Cancel'),
                        ],
                        biometricOnly: false,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to authenticate.'),
                          ),
                        );
                      }
                      return;
                    }

                    if (didAuthenticate) {
                      viewModel.toggleAppLock(true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App Lock enabled')),
                        );
                      }
                    }
                  } else {
                    viewModel.toggleAppLock(false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('App Lock disabled')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Gemini API Key'),
                subtitle: Text(
                  viewModel.settings.geminiApiKey != null && viewModel.settings.geminiApiKey!.isNotEmpty ? 'Saved' : 'Unset',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => _showApiKeyDialog(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }
}