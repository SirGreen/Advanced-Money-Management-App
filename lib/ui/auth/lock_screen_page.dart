import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class LockScreenPage extends StatefulWidget {
  final VoidCallback onUnlock;
  const LockScreenPage({super.key, required this.onUnlock});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _triggerAuth();
  }

  Future<void> _triggerAuth() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access your financial data.',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'App Locked',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(cancelButton: 'Cancel'),
        ],
        biometricOnly: false, // Allows falling back to Device PIN/Passcode
      );
      if (didAuthenticate) {
        widget.onUnlock();
      }
    } catch (e) {
      developer.log('Authentication error', error: e, name: 'LockScreenPage');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'App is Locked',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isAuthenticating ? null : _triggerAuth,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Tap to Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
