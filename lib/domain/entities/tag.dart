import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 1)
class Tag extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int colorValue;
  @HiveField(3)
  String? iconName;
  @HiveField(4)
  String? imagePath;
  @HiveField(5)
  double? budgetAmount;
  @HiveField(6)
  String budgetInterval;

  Tag({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconName,
    this.imagePath,
    this.budgetAmount,
    this.budgetInterval = 'None',
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'iconName': iconName,
    'imagePath': imagePath,
    'budgetAmount': budgetAmount,
    'budgetInterval': budgetInterval,
  };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: json['id'],
    name: json['name'],
    colorValue: json['colorValue'],
    iconName: json['iconName'],
    imagePath: json['imagePath'],
    budgetAmount: json['budgetAmount'],
    budgetInterval: json['budgetInterval'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
