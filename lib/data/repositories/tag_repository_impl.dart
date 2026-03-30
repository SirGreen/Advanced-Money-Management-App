import '../../domain/entities/settings.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../data_sources/llm_service.dart';
import '../data_sources/tag_service.dart';

class TagRepositoryImpl implements TagRepository {
  final TagService _tags;
  final LLMService _llm;

  TagRepositoryImpl(this._tags, this._llm);

  @override
  Future<List<Tag>> getAllTags() async {
    var models = await _tags.getAll();
    // Tags are now seeded by the ViewModel, so we just return what's in the database
    return models.toList();
  }

  @override
  Future<void> addTag(Tag tag) async {
    await _tags.add(tag);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    await _tags.update(tag);
  }

  @override
  Future<void> deleteTag(String tagId) async {
    await _tags.delete(tagId);
  }

  @override
  Future<Map<String, dynamic>?> recommendTags(
    Settings settings,
    String articleName,
    List<String> existingTagNames,
  ) async {
    return await _llm.recommendTags(settings, articleName, existingTagNames);
  }
}
