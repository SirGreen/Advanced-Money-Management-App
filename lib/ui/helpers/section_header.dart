import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double baseFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14.0;
    baseFontSize *= 1.3 ;
    final titleTextStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white, 
          fontSize: baseFontSize,
          letterSpacing: 1.2,
        );

    final titleGradient = LinearGradient(
      colors: [Colors.green.shade900, Colors.green.shade600],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ShaderMask(
        shaderCallback: (bounds) => titleGradient.createShader(bounds),
        child: Text(
          title,
          style: titleTextStyle,
        ),
      ),
    );
  }
}