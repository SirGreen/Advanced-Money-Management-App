import 'package:hive/hive.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/entities/tag.dart';
import '../data_sources/hive_service.dart';

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(HiveService hiveService);

  Future<Box<Tag>> get _box async {
    if (!Hive.isBoxOpen('tags')) {
      await Hive.openBox<Tag>('tags');
    }
    return Hive.box<Tag>('tags');
  }

  @override
  Future<List<Tag>> getTags() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> addTag(Tag tag) async {
    final box = await _box;
    await box.put(tag.id, tag);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final box = await _box;
    await box.put(tag.id, tag);
  }

  @override
  Future<void> deleteTag(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
