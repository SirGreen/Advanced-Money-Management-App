import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../helpers/currency_input_formatter.dart';
import '../../domain/entities/tag.dart';
import '../../l10n/app_localizations.dart';
import 'tag_view_model.dart';
import 'package:uuid/uuid.dart';

class AddEditTagPage extends StatefulWidget {
  final Tag? tag;
  const AddEditTagPage({super.key, this.tag});

  @override
  State<AddEditTagPage> createState() => _AddEditTagPageState();
}

class _AddEditTagPageState extends State<AddEditTagPage> {
  late TextEditingController nameCtrl;
  late TextEditingController budgetAmountCtrl;
  Color color = Colors.blue;
  String? iconName;
  bool isBudgetEnabled = false;
  String budgetInterval = 'Monthly';

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.tag?.name ?? '');
    budgetAmountCtrl = TextEditingController(
      text: widget.tag?.budgetAmount?.toStringAsFixed(0) ?? '',
    );
    if (widget.tag != null) {
      color = Color(widget.tag!.colorValue);
      iconName = widget.tag!.iconName;
      isBudgetEnabled =
          widget.tag!.budgetAmount != null && widget.tag!.budgetAmount! > 0;
      budgetInterval = widget.tag!.budgetInterval == 'None'
          ? 'Monthly'
          : widget.tag!.budgetInterval;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    budgetAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final vm = context.read<TagViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag == null ? l10n.addNewTag : l10n.editTag),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              enabled: widget.tag?.isDefault != true,
            ),
            const SizedBox(height: 12),
            IgnorePointer(
              ignoring: widget.tag?.isDefault == true,
              child: Row(
                children: [
                Text("${l10n.icon}: "),
                const SizedBox(width: 8),
                ...[null, 'fastfood', 'movie', 'directions_car'].map((n) {
                  final ic = _iconForName(n);
                  final selected = iconName == n;
                  return IconButton(
                    onPressed: () {
                      setState(() => iconName = n);
                    },
                    icon: Icon(ic, color: selected ? Colors.blue : null),
                  );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IgnorePointer(
              ignoring: widget.tag?.isDefault == true,
              child: Row(
                children: [
                Text("${l10n.color}: "),
                const SizedBox(width: 8),
                ...[
                  0xFFF48FB1,
                  0xFF90CAF9,
                  0xFF80CBC4,
                  0xFFFFF176,
                  0xFFCE93D8,
                ].map(
                  (v) => GestureDetector(
                    onTap: () => setState(() => color = Color(v)),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(v),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.toARGB32() == v
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Kích hoạt Ngân sách định mức'),
              value: isBudgetEnabled,
              onChanged: (val) => setState(() => isBudgetEnabled = val),
              contentPadding: EdgeInsets.zero,
            ),
            if (isBudgetEnabled) ...[
              const SizedBox(height: 8),
              TextField(
                controller: budgetAmountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Số tiền ngân sách',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  DecimalCurrencyInputFormatter(locale: l10n.localeName),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: budgetInterval,
                decoration: const InputDecoration(
                  labelText: 'Chu kỳ',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'Weekly', child: Text('Hàng tuần')),
                  DropdownMenuItem(value: 'Monthly', child: Text('Hàng tháng')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => budgetInterval = val);
                },
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final parsedBudget = isBudgetEnabled
                    ? double.tryParse(
                        budgetAmountCtrl.text.replaceAll('.', '').replaceAll(',', ''),
                      )
                    : null;
                final tag = Tag(
                  id: widget.tag?.id ?? const Uuid().v4(),
                  name: nameCtrl.text,
                  colorValue: color.toARGB32(),
                  iconName: iconName,
                  budgetAmount: parsedBudget,
                  budgetInterval: isBudgetEnabled ? budgetInterval : 'None',
                  isDefault: widget.tag?.isDefault ?? false,
                  imagePath: widget.tag?.imagePath,
                );
                  widget.tag == null
                      ? await vm.create(tag)
                      : await vm.edit(tag);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Lưu'),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForName(String? name) {
    switch (name) {
      case 'fastfood':
        return Icons.fastfood;
      case 'movie':
        return Icons.movie;
      case 'directions_car':
        return Icons.directions_car;
      default:
        return Icons.label;
    }
  }
}
