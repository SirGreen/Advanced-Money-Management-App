import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/tag.dart';
import '../helpers/tag_icon_mapper.dart';

class TagIcon extends StatelessWidget {
  final Tag tag;
  final double radius;

  const TagIcon({super.key, required this.tag, this.radius = 20.0});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: HSLColor.fromColor(Color(tag.colorValue))
          .withLightness(
            (HSLColor.fromColor(Color(tag.colorValue)).lightness * 0.8).clamp(
              0.0,
              1.0,
            ),
          )
          .toColor()
          .withValues(alpha: 0.2),

      backgroundImage: tag.imagePath != null
          ? FileImage(File(tag.imagePath!))
          : null,

      child: Builder(
        builder: (context) {
          if (tag.imagePath != null) {
            return const SizedBox.shrink();
          }

          if (tag.iconName != null) {
            IconData iconToDisplay;
            switch (tag.iconName) {
              case 'fastfood':
                iconToDisplay = Icons.fastfood;
                break;
              case 'directions_car':
                iconToDisplay = Icons.directions_car;
                break;
              case 'directions_bus':
                iconToDisplay = Icons.directions_bus;
                break;
              case 'shopping_bag':
                iconToDisplay = Icons.shopping_bag;
                break;
              case 'attach_money':
                iconToDisplay = Icons.attach_money;
                break;
              default:
                iconToDisplay = getIconForTag(tag.iconName!);
            }
            return Icon(
              iconToDisplay,
              color: Color(tag.colorValue),
              size: radius,
            );
          }

          return Text(
            tag.name.isNotEmpty ? tag.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Color(tag.colorValue),
              fontWeight: FontWeight.bold,
              fontSize: radius,
            ),
          );
        },
      ),
    );
  }
}
