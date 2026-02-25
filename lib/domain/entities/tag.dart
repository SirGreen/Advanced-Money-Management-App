import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 1)
class Tag extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final bool isDefault;

  @HiveField(4)
  final String? iconName;

  @HiveField(5)
  final String? imagePath;

  Tag({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isDefault = false,
    this.iconName,
    this.imagePath,
  });
}