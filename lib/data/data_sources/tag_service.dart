import 'package:hive/hive.dart';
import '../../domain/entities/tag.dart';

class TagService {
  Future<Box<Tag>> getBox() async {
    if (!Hive.isBoxOpen('tags')) {
      await Hive.openBox<Tag>('tags');
    }
    return Hive.box<Tag>('tags');
  }

  Future<List<Tag>> getAll() async {
    final box = await getBox();
    return box.values.toList();
  }

  Future<void> add(Tag item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> update(Tag item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> delete(String id) async {
    final box = await getBox();
    await box.delete(id);
  }
}
