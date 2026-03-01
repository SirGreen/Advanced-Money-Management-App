import '../../domain/entities/tag.dart';

class TagModel {
  final String id;
  final String name;
  final int colorValue;
  final bool isDefault;
  final String? iconName;
  final String? imagePath;

  TagModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isDefault = false,
    this.iconName,
    this.imagePath,
  });

  factory TagModel.fromEntity(Tag tag) => TagModel(
    id: tag.id,
    name: tag.name,
    colorValue: tag.colorValue,
    isDefault: tag.isDefault,
    iconName: tag.iconName,
    imagePath: tag.imagePath,
  );

  Tag toEntity() => Tag(
    id: id,
    name: name,
    colorValue: colorValue,
    isDefault: isDefault,
    iconName: iconName,
    imagePath: imagePath,
  );
}
