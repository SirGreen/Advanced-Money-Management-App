import 'package:flutter/material.dart';
import '../../domain/entities/tag.dart';
import 'add_edit_tag_page.dart';

class TagDetailPage extends StatelessWidget {
  final Tag tag;
  const TagDetailPage({required this.tag, Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết danh mục')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(tag.colorValue),
                  child: Icon(
                    _iconForName(tag.iconName),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(tag.name, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 24),
            if (tag.isDefault)
              const Text('Danh mục mặc định, không thể chỉnh sửa.')
            else
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditTagPage(tag: tag)),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Sửa'),
              ),
          ],
        ),
      ),
    );
  }
}
