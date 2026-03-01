import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/tag.dart';
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
  Color color = Colors.blue;
  String? iconName;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.tag?.name ?? '');
    if (widget.tag != null) {
      color = Color(widget.tag!.colorValue);
      iconName = widget.tag!.iconName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TagViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag == null ? 'Thêm danh mục' : 'Sửa danh mục'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Biểu tượng:'),
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Màu:'),
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
                          color: color.value == v
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
            const SizedBox(height: 16),
            if (widget.tag?.isDefault == true)
              const Text('Danh mục mặc định, không thể chỉnh sửa.')
            else
              ElevatedButton(
                onPressed: () async {
                  final tag = Tag(
                    id: widget.tag?.id ?? const Uuid().v4(),
                    name: nameCtrl.text,
                    colorValue: color.value,
                    iconName: iconName,
                  );
                  widget.tag == null
                      ? await vm.create(tag)
                      : await vm.edit(tag);
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
