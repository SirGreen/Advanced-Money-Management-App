import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'tag_view_model.dart';
import 'tag_detail_page.dart';
import 'add_edit_tag_page.dart';

class ManageTagsPage extends StatelessWidget {
  const ManageTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<TagViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tags)),
      body: ListView(
        children: vm.tags
            .map(
              (t) => ListTile(
                title: Text(t.name),
                leading: CircleAvatar(
                  backgroundColor: Color(t.colorValue),
                  child: Icon(_iconForName(t.iconName), color: Colors.white),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TagDetailPage(tag: t)),
                ),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditTagPage()),
        ),
        child: const Icon(Icons.add),
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
