import '../entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getAllTags();
  Future<void> addTag(Tag tag);
  Future<void> updateTag(Tag tag);
}
