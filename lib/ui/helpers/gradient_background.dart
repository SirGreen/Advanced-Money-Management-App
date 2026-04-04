import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  final Widget child;

  const BackGround({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/appBackgroundImg.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        child,
      ],
    );
  }
}

// import 'package:flutter/material.dart';

// class GradientBackground extends StatelessWidget {
//   final Widget child;
//   final List<Color>? colors;

//   const GradientBackground({
//     super.key,
//     required this.child,
//     this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final gradientColors = colors ?? [
//       const Color.fromARGB(255, 158, 210, 159),
//       const Color.fromARGB(255, 210, 238, 212),
//       Colors.lightBlue.shade100,
//     ];

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: gradientColors,
//         ),
//       ),
//       child: child,
//     );
//   }
// }
