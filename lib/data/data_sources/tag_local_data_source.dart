import '../models/tag_model.dart';

class TagLocalDataSource {
  final List<TagModel> _storage = [
    TagModel(
      id: 'default_eat',
      name: 'Ăn uống',
      colorValue: 0xFFF48FB1, // pink
      iconName: 'fastfood',
      isDefault: true,
    ),
    TagModel(
      id: 'default_entertainment',
      name: 'Giải trí',
      colorValue: 0xFF90CAF9, // light blue
      iconName: 'movie',
      isDefault: true,
    ),
    TagModel(
      id: 'default_transport',
      name: 'Phương tiện',
      colorValue: 0xFF80CBC4, // teal
      iconName: 'directions_car',
      isDefault: true,
    ),
  ];
  
  Future<List<TagModel>> getAll() async {
    return List<TagModel>.from(_storage);
  }

  Future<void> add(TagModel tag) async {
    // ensure user-created tags are not marked as default
    final toAdd = TagModel(
      id: tag.id,
      name: tag.name,
      colorValue: tag.colorValue,
      iconName: tag.iconName,
      imagePath: tag.imagePath,
      isDefault: false,
    );
    _storage.add(toAdd);
  }

  Future<void> update(TagModel tag) async {
    final index = _storage.indexWhere((e) => e.id == tag.id);
    if (index != -1) {
      // do not allow updating default tags
      if (_storage[index].isDefault) return;
      _storage[index] = tag;
    }
  }
}