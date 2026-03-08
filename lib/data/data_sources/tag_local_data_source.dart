import 'package:adv_money_mana/domain/entities/tag.dart';

class TagLocalDataSource {
  final List<Tag> _storage = [
    Tag(
      id: 'default_eat',
      name: 'Ăn uống',
      colorValue: 0xFFF48FB1, // pink
      iconName: 'fastfood',
      isDefault: true,
    ),
    Tag(
      id: 'default_entertainment',
      name: 'Giải trí',
      colorValue: 0xFF90CAF9, // light blue
      iconName: 'movie',
      isDefault: true,
    ),
    Tag(
      id: 'default_transport',
      name: 'Phương tiện',
      colorValue: 0xFF80CBC4, // teal
      iconName: 'directions_car',
      isDefault: true,
    ),
  ];

  Future<List<Tag>> getAll() async {
    return List<Tag>.from(_storage);
  }

  Future<void> add(Tag tag) async {
    // ensure user-created tags are not marked as default
    final toAdd = Tag(
      id: tag.id,
      name: tag.name,
      colorValue: tag.colorValue,
      iconName: tag.iconName,
      imagePath: tag.imagePath,
      isDefault: false,
    );
    _storage.add(toAdd);
  }

  Future<void> update(Tag tag) async {
    final index = _storage.indexWhere((e) => e.id == tag.id);
    if (index != -1) {
      // do not allow updating default tags
      if (_storage[index].isDefault) return;
      _storage[index] = tag;
    }
  }
}
