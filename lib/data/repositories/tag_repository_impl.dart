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

    // Check if we have the new tags (should be 7 tags with specific IDs)
    final expectedTagIds = {
      'entertainment',
      'food',
      'income',
      'savings',
      'shopping',
      'transport',
      'other'
    };
    final currentTagIds = models.map((t) => t.id).toSet();

    // If tags are missing or outdated, reseed with new ones
    if (models.isEmpty || !expectedTagIds.every((id) => currentTagIds.contains(id))) {
      await seedDefaultTags();
      models = await _tags.getAll();
    }

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
  Future<void> seedDefaultTags() async {
    // Delete old Vietnamese tags if they exist
    final allTags = await _tags.getAll();
    final oldTagNames = {'ăn uống', 'giải trí', 'phương tiện'};

    for (final tag in allTags) {
      if (oldTagNames.contains(tag.name)) {
        try {
          await _tags.delete(tag.id);
        } catch (e) {
          // ignore: avoid_print
          print("Error deleting old tag ${tag.name}: $e");
        }
      }
    }

    final defaults = [
      Tag(
        id: 'entertainment',
        name: 'Entertainment',
        colorValue: 0xFF9C27B0,
        iconName: 'entertainment',
      ),
      Tag(
        id: 'food',
        name: 'Food',
        colorValue: 0xFFFF5722,
        iconName: 'food',
      ),
      Tag(
        id: 'income',
        name: 'Income',
        colorValue: 0xFF4CAF50,
        iconName: 'income',
      ),
      Tag(
        id: 'savings',
        name: 'Savings',
        colorValue: 0xFF00BCD4,
        iconName: 'savings',
      ),
      Tag(
        id: 'shopping',
        name: 'Shopping',
        colorValue: 0xFFE91E63,
        iconName: 'shopping',
      ),
      Tag(
        id: 'transport',
        name: 'Transport',
        colorValue: 0xFF2196F3,
        iconName: 'transport',
      ),
      Tag(
        id: 'other',
        name: 'Other',
        colorValue: 0xFF607D8B,
        iconName: 'other',
      ),
    ];

    for (final tag in defaults) {
      await _tags.add(tag);
    }
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
