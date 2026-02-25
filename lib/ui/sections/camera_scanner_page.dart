import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/expenditure_controller.dart';
import '../../../domain/entities/tag.dart';
import 'add_edit_expenditure_page.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../../../l10n/app_localizations.dart';

class CameraScannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  const CameraScannerAppBar({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          title: GradientTitle(text: l10n.scanReceipt),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage({super.key});
  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  bool _isProcessing = false;

  Future<void> _getImageAndProcess(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null || !mounted) return;

    setState(() => _isProcessing = true);

    final expenditureController = Provider.of<ExpenditureController>(context, listen: false);
    
    // Gọi hàm xử lý từ controller
    final parsedData = await expenditureController.processReceipt(File(pickedFile.path));

    if (!mounted) {
      setState(() => _isProcessing = false);
      return;
    }

    String? prefilledName;
    double? prefilledAmount;
    List<Tag> recommendedTags = [];
    String? memo;

    if (parsedData != null) {
      prefilledName = parsedData['store_name'] as String?;
      
      final amountValue = parsedData['total_amount'];
      if (amountValue is num) {
        prefilledAmount = amountValue.toDouble();
      } else if (amountValue is String) {
        prefilledAmount = double.tryParse(amountValue.replaceAll(',', ''));
      }

      if (parsedData['recommended_tags'] is List) {
        List<String> suggestedNames = List<String>.from(parsedData['recommended_tags']);
        recommendedTags = expenditureController.tags
            .where((t) => suggestedNames.contains(t.name))
            .toList();
      }
      memo = parsedData['memo'] as String?;
    }

    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AddEditExpenditurePage(
          prefilledName: prefilledName,
          prefilledAmount: prefilledAmount,
          prefilledTags: recommendedTags,
          prefilledReceiptPath: pickedFile.path,
          prefilledMemo: memo,
        ),
      ),
    );
  }

  // Helper build card UI giữ nguyên như cũ...
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return SizedBox(
      width: 200,
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CameraScannerAppBar(l10n: l10n),
        body: Stack(
          children: [
            Center(
              child: Wrap(
                spacing: 24,
                children: [
                  _buildOptionCard(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    title: l10n.takePicture,
                    subtitle: l10n.useYourCameraToScan,
                    onTap: () => _getImageAndProcess(ImageSource.camera),
                  ),
                  _buildOptionCard(
                    context: context,
                    icon: Icons.photo_library_outlined,
                    title: l10n.selectFromGallery,
                    subtitle: l10n.uploadAnExistingImage,
                    onTap: () => _getImageAndProcess(ImageSource.gallery),
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: GlassCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(l10n.analyzingYourReceipt),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}