import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../data_sources/tag_local_data_source.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDataSource local;

  TagRepositoryImpl(this.local);

  @override
  Future<List<Tag>> getAllTags() async {
    final models = await local.getAll();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addTag(Tag tag) async {
    await local.add(TagModel.fromEntity(tag));
  }

  @override
  Future<void> updateTag(Tag tag) async {
    await local.update(TagModel.fromEntity(tag));
  }
}