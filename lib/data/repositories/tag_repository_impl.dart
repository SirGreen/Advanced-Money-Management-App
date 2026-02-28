import '../../domain/repositories/tag_repository.dart';
import '../../domain/entities/tag.dart';
import '../data_sources/tag_service.dart';

class TagRepositoryImpl implements TagRepository {
  final TagService _service;

  TagRepositoryImpl(this._service);

  @override
  Future<List<Tag>> getTags() => _service.getAll();

  @override
  Future<void> addTag(Tag tag) => _service.add(tag);

  @override
  Future<void> updateTag(Tag tag) => _service.update(tag);

  @override
  Future<void> deleteTag(String id) => _service.delete(id);
}
