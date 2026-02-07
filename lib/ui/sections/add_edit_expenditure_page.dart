import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../controllers/expenditure_controller.dart';
import '../controllers/settings_controller.dart';
import '../../domain/entities/tag.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
// ignore: unused_import
import '../helpers/tag_icon.dart'; 
import '../../l10n/app_localizations.dart';

class AddEditExpenditureAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;

  const AddEditExpenditureAppBar({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          title: GradientTitle(
            text: l10n.addTransaction, // Luôn là Thêm mới vì từ màn hình Scan qua
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AddEditExpenditurePage extends StatefulWidget {
  // Các tham số nhận từ CameraScannerPage (kết quả sau khi Scan)
  final String? prefilledName;
  final double? prefilledAmount;
  final List<Tag>? prefilledTags;
  final String? prefilledReceiptPath;
  final String? prefilledMemo;

  const AddEditExpenditurePage({
    super.key,
    this.prefilledName,
    this.prefilledAmount,
    this.prefilledTags,
    this.prefilledReceiptPath,
    this.prefilledMemo,
  });

  @override
  State<AddEditExpenditurePage> createState() => _AddEditExpenditurePageState();
}

class _AddEditExpenditurePageState extends State<AddEditExpenditurePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers cho các trường nhập liệu
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  
  late DateTime _selectedDate;
  String? _selectedMainTagId;
  late List<String> _selectedSubTagIds;
  bool _isIncome = false; // Mặc định là Chi tiêu (Expense) khi quét hóa đơn
  
  String? _receiptPath;
  File? _tempReceiptFile;
  
  // Logic gợi ý Tag
  List<Object> _recommendedItems = [];
  bool _isFetchingRecommendations = false;

  @override
  void initState() {
    super.initState();
    final formatter = NumberFormat('#,###');
    
    // 1. Điền dữ liệu từ kết quả Scan vào Form
    _nameController = TextEditingController(text: widget.prefilledName ?? '');
    
    final double? initialAmount = widget.prefilledAmount;
    _amountController = TextEditingController(
      text: initialAmount != null ? formatter.format(initialAmount) : '',
    );
    
    _notesController = TextEditingController(text: widget.prefilledMemo ?? '');
    
    _selectedDate = DateTime.now();
    _receiptPath = widget.prefilledReceiptPath;

    // 2. Xử lý Tags được AI gợi ý
    if (widget.prefilledTags != null && widget.prefilledTags!.isNotEmpty) {
      _selectedMainTagId = widget.prefilledTags![0].id;
      _selectedSubTagIds = widget.prefilledTags!.length > 1
          ? widget.prefilledTags!.sublist(1).map((t) => t.id).toList()
          : [];
    } else {
      _selectedMainTagId = null;
      _selectedSubTagIds = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- LOGIC LƯU DỮ LIỆU ---
  Future<void> _saveForm() async {
    final l10n = AppLocalizations.of(context)!;
    final expenditureController = Provider.of<ExpenditureController>(context, listen: false);
    final settings = Provider.of<SettingsController>(context, listen: false).settings;

    // Tự động sinh tên nếu trống
    if (_nameController.text.isEmpty) {
      final date = DateFormat.Hms(l10n.localeName).format(_selectedDate);
      _nameController.text = 'Scan - $date';
    }

    // Logic chọn Tag mặc định nếu người dùng không chọn
    _selectedMainTagId ??= ExpenditureController.defaultTagId;

    // Xử lý lưu file ảnh vào thư mục ứng dụng (Persist Image)
    String? finalReceiptPath = _receiptPath;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      
      if (_tempReceiptFile != null) {
        // Trường hợp 1: Người dùng chụp lại ảnh mới trong màn hình này
        final fileName = path.basename(_tempReceiptFile!.path);
        final savedImage = await _tempReceiptFile!.copy('${appDir.path}/$fileName');
        finalReceiptPath = savedImage.path;
      } else if (_receiptPath != null) {
         // Trường hợp 2: Dùng ảnh từ OCR scan (cần copy từ cache vào app folder để lưu lâu dài)
        final sourceFile = File(_receiptPath!);
        final fileName = path.basename(sourceFile.path);
        final destinationPath = '${appDir.path}/$fileName';
        
        // Kiểm tra xem đã lưu chưa để tránh copy đè
        if (sourceFile.path != destinationPath) {
             await sourceFile.copy(destinationPath);
             finalReceiptPath = destinationPath;
        }
      }
    } catch (e) {
        debugPrint("Error saving image: $e");
    }

    final amountInput = double.tryParse(_amountController.text.replaceAll(',', ''));
    
    // Gọi Controller để lưu vào Database (Local Storage)
    await expenditureController.addExpenditure(
      settings,
      articleName: _nameController.text,
      amount: amountInput,
      date: _selectedDate,
      mainTagId: _selectedMainTagId!,
      subTagIds: _selectedSubTagIds,
      isIncome: _isIncome,
      notes: _notesController.text,
      receiptImagePath: finalReceiptPath,
    );

    if (mounted) {
      // Quay về trang chủ sau khi lưu thành công
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Chụp lại ảnh (nếu ảnh OCR mờ hoặc muốn thay đổi)
  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _tempReceiptFile = File(pickedFile.path);
        _receiptPath = null; // Reset đường dẫn cũ
      });
    }
  }

  // Logic xử lý UI chọn Tag
  void _handleTagSelection(String tagId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectedMainTagId == null) {
          _selectedMainTagId = tagId;
        } else if (!_selectedSubTagIds.contains(tagId)) {
          _selectedSubTagIds.add(tagId);
        }
      } else {
        if (_selectedMainTagId == tagId) {
          _selectedMainTagId = _selectedSubTagIds.isNotEmpty
              ? _selectedSubTagIds.removeAt(0)
              : null;
        } else {
          _selectedSubTagIds.remove(tagId);
        }
      }
    });
  }

  // Logic gọi Controller để gợi ý thêm Tag (Manual trigger)
  Future<void> _getRecommendations() async {
    if (_nameController.text.length < 3) return;
    
    setState(() {
      _isFetchingRecommendations = true;
      _recommendedItems = [];
    });
    
    final controller = Provider.of<ExpenditureController>(context, listen: false);
    final recommendations = await controller.recommendTags(_nameController.text);
    
    if (mounted) {
      setState(() {
        _recommendedItems = recommendations;
        _isFetchingRecommendations = false;
      });
    }
  }

  Future<void> _applyRecommendation(Object recommendation) async {
      final expenditureController = Provider.of<ExpenditureController>(context, listen: false);
      String? tagIdToApply;

      if (recommendation is String) {
        // Tạo tag mới nếu AI gợi ý chuỗi string chưa có trong DB
        tagIdToApply = const Uuid().v4();
        await expenditureController.addTag(
          id: tagIdToApply,
          name: recommendation,
          // ignore: deprecated_member_use
          colorValue: Colors.grey.value,
          iconName: 'label',
        );
      } else if (recommendation is Tag) {
        tagIdToApply = recommendation.id;
      }

      if (tagIdToApply != null && mounted) {
        _handleTagSelection(tagIdToApply, true);
        setState(() {
           _recommendedItems.remove(recommendation);
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addEditAppBar = AddEditExpenditureAppBar(l10n: l10n);
    final double appBarHeight = addEditAppBar.preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: addEditAppBar,
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, totalTopOffset + 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPrimaryInfoCard(context, l10n),
                    const SizedBox(height: 24),
                    Center(child: _buildTypeSelector(context, l10n)),
                    const SizedBox(height: 24),
                    _buildTagSelector(context, l10n),
                    const SizedBox(height: 24),
                    _buildDetailsSection(context, l10n),
                  ]),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveForm,
          label: Text(l10n.save),
          icon: const Icon(Icons.check_rounded),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // --- CÁC WIDGET CON (Sub-Widgets) ---

  Widget _buildPrimaryInfoCard(BuildContext context, AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // Nhập số tiền
          TextFormField(
            controller: _amountController,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              prefixText: '¥ ', // Hoặc lấy currency symbol từ Settings
              prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade600,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => (v != null && v.isNotEmpty && double.tryParse(v.replaceAll(',', '')) == null)
                ? l10n.validNumber
                : null,
          ),
          const Divider(height: 24),
          // Nhập tên giao dịch (Article Name)
          TextFormField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: l10n.articleName,
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? l10n.nameInput : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, AppLocalizations l10n) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment<bool>(
          value: false,
          label: Text(l10n.expense),
          icon: const Icon(Icons.arrow_downward_rounded),
        ),
        ButtonSegment<bool>(
          value: true,
          label: Text(l10n.income),
          icon: const Icon(Icons.arrow_upward_rounded),
        ),
      ],
      selected: {_isIncome},
      onSelectionChanged: (newSelection) => setState(() => _isIncome = newSelection.first),
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        selectedBackgroundColor: _isIncome ? Colors.green.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildTagSelector(BuildContext context, AppLocalizations l10n) {
    final controller = Provider.of<ExpenditureController>(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text(l10n.tags, style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                if (controller.tags.isEmpty)
                   Text(l10n.noTagsYet, style: const TextStyle(color: Colors.grey))
                else
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: controller.tags.map((tag) {
                      final isSelected = _selectedMainTagId == tag.id || _selectedSubTagIds.contains(tag.id);
                      return FilterChip(
                        label: Text(tag.name),
                        // avatar: TagIcon(tag: tag, radius: 10), // Uncomment nếu có TagIcon
                        selected: isSelected,
                        onSelected: (selected) => _handleTagSelection(tag.id, selected),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                
                // Nút Gợi ý Tag (AI Recommendation)
                if (!_isFetchingRecommendations)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: Text(l10n.suggestTags),
                    onPressed: _getRecommendations,
                  ),
                ),
                 if (_isFetchingRecommendations)
                  const LinearProgressIndicator(),
                 
                 if (_recommendedItems.isNotEmpty)
                   Wrap(
                     spacing: 8.0,
                     children: _recommendedItems.map((item) {
                       return ActionChip(
                         label: Text(item is Tag ? item.name : item.toString()),
                         onPressed: () => _applyRecommendation(item),
                         avatar: const Icon(Icons.auto_awesome, size: 14),
                       );
                     }).toList(),
                   )
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, AppLocalizations l10n) {
    // Xác định ảnh hiển thị: ưu tiên ảnh mới chụp > ảnh OCR path
    final imageToShow = _tempReceiptFile != null
        ? FileImage(_tempReceiptFile!)
        : (_receiptPath != null ? FileImage(File(_receiptPath!)) : null);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chọn Ngày
          InkWell(
            onTap: _pickDate,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.date, style: Theme.of(context).textTheme.bodyLarge),
                Row(
                  children: [
                    Text(
                      DateFormat.yMMMd(l10n.localeName).format(_selectedDate),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Ghi chú (Memo từ OCR sẽ vào đây)
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              hintText: l10n.notesHint,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.5),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // Hiển thị ảnh hóa đơn
          Text(l10n.receipt, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickReceiptImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                image: imageToShow != null 
                    ? DecorationImage(image: imageToShow, fit: BoxFit.cover)
                    : null,
              ),
               child: imageToShow == null
                  ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey))
                  : null,
            ),
          )
        ],
      ),
    );
  }
}