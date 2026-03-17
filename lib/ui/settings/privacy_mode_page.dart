import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_view_model.dart';
import '../widgets/privacy_mode_widgets.dart';

class PrivacyModePage extends StatefulWidget {
  const PrivacyModePage({super.key});

  @override
  State<PrivacyModePage> createState() => _PrivacyModePageState();
}

class _PrivacyModePageState extends State<PrivacyModePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Mode Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) {
          final privacyModeEnabled = viewModel.settings.privacyModeEnabled;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Privacy Mode Toggle
                  PrivacyModeTile(
                    privacyModeEnabled: privacyModeEnabled,
                    onChanged: (value) async {
                      await viewModel.togglePrivacyMode(value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Privacy Mode enabled'
                                  : 'Privacy Mode disabled',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Information Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'What Privacy Mode Does',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            icon: Icons.money_off,
                            title: 'Hides Amounts',
                            description:
                                'All financial amounts are shown as "•••" to prevent shoulder surfing',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            icon: Icons.text_fields,
                            title: 'Blurs Details',
                            description:
                                'Transaction names and descriptions are obscured',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            icon: Icons.bar_chart,
                            title: 'Protects Reports',
                            description:
                                'Charts, graphs, and reports display masked data',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            icon: Icons.lock,
                            title: 'Secure Display',
                            description:
                                'Visual lock icons indicate where data is hidden',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Features Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Protected Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureRow('Transaction amounts'),
                          _buildFeatureRow('Account balances'),
                          _buildFeatureRow('Total savings'),
                          _buildFeatureRow('Budget information'),
                          _buildFeatureRow('Transaction descriptions'),
                          _buildFeatureRow('Report data'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Persistent Settings Section
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Settings Saved',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Your Privacy Mode preference is automatically saved and will persist when you close and reopen the app.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: privacyModeEnabled
                          ? Colors.amber.shade50
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: privacyModeEnabled
                            ? Colors.amber.shade400
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              privacyModeEnabled ? Icons.lock : Icons.lock_open,
                              color: privacyModeEnabled
                                  ? Colors.amber[700]
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              privacyModeEnabled
                                  ? 'Privacy Mode is ON'
                                  : 'Privacy Mode is OFF',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: privacyModeEnabled
                                    ? Colors.amber[700]
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          privacyModeEnabled
                              ? 'Your financial data is being protected from view'
                              : 'All financial information is currently visible',
                          style: TextStyle(
                            fontSize: 12,
                            color: privacyModeEnabled
                                ? Colors.amber[600]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check, size: 18, color: Colors.green[600]),
          const SizedBox(width: 8),
          Text(feature, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
