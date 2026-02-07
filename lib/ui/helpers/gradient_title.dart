import 'package:flutter/material.dart';

class GradientTitle extends StatelessWidget {
  final String text;
  final List<Color>? gradientColors;

  const GradientTitle({
    super.key,
    required this.text,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [
      const Color.fromARGB(255, 30, 98, 36), // Darker green
      const Color.fromARGB(255, 51, 137, 166), // Lighter green
    ];

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}