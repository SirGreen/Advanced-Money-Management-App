import '../entities/settings.dart';
import '../entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getAllTags();
  Future<void> addTag(Tag tag);
  Future<void> updateTag(Tag tag);
  Future<void> deleteTag(String tagId);
  Future<void> seedDefaultTags();

  Future<Map<String, dynamic>?> recommendTags(
    Settings settings,
    String articleName,
    List<String> existingTagNames,
  );
}
