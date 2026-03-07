import 'package:flutter/material.dart';
import '../../data/services/privacy_mode_service.dart';

/// Widget to display amount with privacy mode support
class PrivacyAwareAmount extends StatelessWidget {
  final double? amount;
  final String currency;
  final bool privacyModeEnabled;
  final TextStyle? style;
  final int decimalPlaces;

  const PrivacyAwareAmount({
    super.key,
    required this.amount,
    required this.currency,
    required this.privacyModeEnabled,
    this.style,
    this.decimalPlaces = 2,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmount = amount ?? 0;
    final formattedAmount = privacyModeEnabled
        ? PrivacyModeService.maskSymbol
        : displayAmount.toStringAsFixed(decimalPlaces);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$currency $formattedAmount',
          style: style ?? Theme.of(context).textTheme.bodyLarge,
        ),
        if (privacyModeEnabled) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.lock,
            size: 14,
            color: Colors.grey[600],
          ),
        ],
      ],
    );
  }
}

/// Widget to display text with privacy mode support
class PrivacyAwareText extends StatelessWidget {
  final String text;
  final bool privacyModeEnabled;
  final TextStyle? style;
  final bool blur;

  const PrivacyAwareText({
    super.key,
    required this.text,
    required this.privacyModeEnabled,
    this.style,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = text;
    if (privacyModeEnabled && blur) {
      displayText = PrivacyModeService.createBlurredText(text);
    }

    return GestureDetector(
      onLongPress: privacyModeEnabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Mode is enabled'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          : null,
      child: Text(
        displayText,
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

/// Privacy Mode Status Indicator
class PrivacyModeIndicator extends StatelessWidget {
  final bool privacyModeEnabled;
  final VoidCallback? onTap;

  const PrivacyModeIndicator({
    super.key,
    required this.privacyModeEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!privacyModeEnabled) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Privacy Mode is ON',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            border: Border.all(color: Colors.amber.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 14, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                'Privacy Mode',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Privacy Mode Toggle Tile for Settings
class PrivacyModeTile extends StatelessWidget {
  final bool privacyModeEnabled;
  final ValueChanged<bool> onChanged;

  const PrivacyModeTile({
    super.key,
    required this.privacyModeEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility_off,
                  color: privacyModeEnabled ? Colors.amber : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Privacy Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        privacyModeEnabled
                            ? 'Hide sensitive financial data'
                            : 'Show all financial information',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: privacyModeEnabled,
                  onChanged: onChanged,
                  activeThumbColor: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'When enabled:\n'
                '• Amounts shown as •••\n'
                '• Transaction names blurred\n'
                '• Reports show masked data\n'
                '• Status remains saved between sessions',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
