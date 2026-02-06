class Tag {
  final String id;
  final String name;
  final int colorValue;
  final bool isDefault;
  final String? iconName;
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