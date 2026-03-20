import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/data_sources/backup_restore_service.dart';
import '../../l10n/app_localizations.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final _backupRestoreService = BackupRestoreService();
  bool _isLoading = false;

  Future<void> _performBackup() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      // Export data to JSON
      final jsonData = await _backupRestoreService.exportAllData();

      // Get downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Unable to access downloads directory');
      }

      // Create backup file with timestamp
      final timestamp = DateTime.now()
          .toString()
          .replaceAll(':', '-')
          .split('.')[0];
      final fileName = 'backup_$timestamp.json';
      final filePath = '${downloadsDir.path}/$fileName';

      // Write backup file
      final file = File(filePath);
      await file.writeAsString(jsonData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data backed up successfully: $filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to backup data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performRestore() async {
    try {
      // Pick a backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        throw Exception('Invalid file path');
      }

      // Confirm before restoring
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Data'),
            content: const Text(
              'Are you sure you want to restore data? Current data will be overwritten.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (!confirmed!) return;

        setState(() => _isLoading = true);

        // Read backup file
        final file = File(filePath);
        final jsonData = await file.readAsString();

        // Restore data
        await _backupRestoreService.importAllData(jsonData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Data restored successfully! Please restart the app to apply changes.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Backup Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save all your financial data to a file for backup and transfer',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _performBackup,
                        icon: const Icon(Icons.backup),
                        label: Text(
                          _isLoading ? 'Backing up...' : 'Export Data',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Restore Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Restore your financial data from a backup file',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _performRestore,
                        icon: const Icon(Icons.restore),
                        label: Text(
                          _isLoading ? 'Restoring...' : 'Import Data',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
