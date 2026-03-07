import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import '../../l10n/app_localizations.dart';
import '../tags/manage_tags_page.dart';
import 'settings_view_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(l10n.tags),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageTagsPage()),
              );
            },
          ),
          const Divider(),
          Consumer<SettingsViewModel>(
            builder: (context, viewModel, child) {
              return SwitchListTile(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
