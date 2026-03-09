import 'package:flutter/material.dart';

import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

class TagViewModel extends ChangeNotifier {
  final TagRepository _repository;

  TagViewModel(this._repository);

  List<Tag> tags = [];

  Future<void> load() async {
    tags = await _repository.getAllTags();
    notifyListeners();
  }

  Future<void> initialize() async {
    await load();
  }

  Future<void> create(Tag tag) async {
    await _repository.addTag(tag);
    await load();
  }

  Future<void> edit(Tag tag) async {
    await _repository.updateTag(tag);
    await load();
  }
}
