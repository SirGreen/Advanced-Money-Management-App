import 'package:flutter/material.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/add_tag.dart';
import '../../domain/usecases/get_all_tags.dart';
import '../../domain/usecases/update_tag.dart';

class TagViewModel extends ChangeNotifier {
  final GetAllTags getAllTags;
  final AddTag addTag;
  final UpdateTag updateTag;

  TagViewModel({
    required this.getAllTags,
    required this.addTag,
    required this.updateTag,
  });

  List<Tag> tags = [];

  Future<void> load() async {
    tags = await getAllTags();
    notifyListeners();
  }

  Future<void> create(Tag tag) async {
    await addTag(tag);
    await load();
  }

  Future<void> edit(Tag tag) async {
    await updateTag(tag);
    await load();
  }
}
