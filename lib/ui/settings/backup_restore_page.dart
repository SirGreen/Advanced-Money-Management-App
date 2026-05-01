import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/data_sources/backup_restore_service.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/section_header.dart';

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
      final jsonData = await _backupRestoreService.exportAllData();

      final timestamp = DateTime.now()
          .toString()
          .replaceAll(':', '-')
          .split('.')[0];
      final fileName = 'backup_$timestamp.json';

      // Let user choose where to save
      // Passing bytes ensures the file is written by the plugin on all platforms
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Chọn nơi lưu file backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonData)),
      );

      if (savePath == null) {
        // User cancelled
        return;
      }

      if (mounted) {
        _showSuccessDialog(
          title: l10n.backupSuccess,
          fileName: fileName,
          savedPath: savePath,
          icon: Icons.backup_rounded,
          iconColor: Colors.teal.shade700,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('${l10n.backupFailed}: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performRestore() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: l10n.selectBackupFile,
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) throw Exception('Invalid file path');

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 36),
          title: Text(l10n.restoreData, textAlign: TextAlign.center),
          content: Text(l10n.confirmRestore),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.restore),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isLoading = true);

      final file = File(filePath);
      final jsonData = await file.readAsString();
      await _backupRestoreService.importAllData(jsonData);

      if (mounted) {
        _showSuccessDialog(
          title: l10n.restoreSuccess,
          fileName: result.files.first.name,
          savedPath: filePath,
          icon: Icons.restore_rounded,
          iconColor: Colors.green.shade700,
          extraNote: 'Khởi động lại ứng dụng để áp dụng thay đổi.',
        );
      }
    } catch (e) {
      if (mounted) {
        final l10nCurrent = AppLocalizations.of(context)!;
        _showErrorSnackBar('${l10nCurrent.restoreFailed}: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog({
    required String title,
    required String fileName,
    required String savedPath,
    required IconData icon,
    required Color iconColor,
    String? extraNote,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: CircleAvatar(
          radius: 28,
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor, size: 34),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            _dialogRow(
              icon: Icons.insert_drive_file_outlined,
              label: 'Tệp',
              value: fileName,
            ),
            const SizedBox(height: 8),
            _dialogRow(
              icon: Icons.folder_outlined,
              label: 'Đường dẫn',
              value: savedPath,
            ),
            if (extraNote != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        extraNote,
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            ),
            child: Text(l10n.end),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.teal.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 90;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(l10n),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, topPadding, 12, bottomPadding),
          child: Column(
            children: [
              _buildBackupCard(context, l10n),
              const SizedBox(height: 16),
              _buildRestoreCard(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: GradientTitle(text: l10n.backupData),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
    );
  }

  Widget _buildBackupCard(BuildContext context, AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.backupData),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.backupDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bạn sẽ được chọn nơi lưu file backup sau khi nhấn nút bên dưới.',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performBackup,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.backup_rounded),
                    label: Text(
                      _isLoading ? 'Đang sao lưu...' : l10n.backupData,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreCard(BuildContext context, AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.restoreData),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.restoreDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Dữ liệu hiện tại sẽ bị ghi đè. Hãy sao lưu trước khi khôi phục.',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performRestore,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.restore_rounded),
                    label: Text(
                      _isLoading ? 'Đang khôi phục...' : l10n.restoreData,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
