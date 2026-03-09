import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../data_sources/tag_service.dart';

class TagRepositoryImpl implements TagRepository {
  final TagService _service;

  TagRepositoryImpl(this._service);

  @override
  Future<List<Tag>> getAllTags() async {
    var models = await _service.getAll();
    if (models.isEmpty) {
      _service.add(
        Tag(
          id: 'default_eat',
          name: 'Ăn uống',
          colorValue: 0xFFF48FB1, // pink
          iconName: 'fastfood',
          isDefault: true,
        ),
      );
      _service.add(
        Tag(
          id: 'default_entertainment',
          name: 'Giải trí',
          colorValue: 0xFF90CAF9, // light blue
          iconName: 'movie',
          isDefault: true,
        ),
      );
      _service.add(
        Tag(
          id: 'default_transport',
          name: 'Phương tiện',
          colorValue: 0xFF80CBC4, // teal
          iconName: 'directions_car',
          isDefault: true,
        ),
      );
      models = await _service.getAll();
    }
    return models.toList();
  }

  @override
  Future<void> addTag(Tag tag) async {
    await _service.add(tag);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    await _service.update(tag);
  }
}
