import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../data_sources/tag_local_data_source.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDataSource local;

  TagRepositoryImpl(this.local);

  @override
  Future<List<Tag>> getAllTags() async {
    final models = await local.getAll();
    return models.toList();
  }

  @override
  Future<void> addTag(Tag tag) async {
    await local.add(tag);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    await local.update(tag);
  }
}
