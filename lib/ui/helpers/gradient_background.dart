import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  final Widget child;

  const BackGround({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // return Container(
    //     decoration: BoxDecoration(
    //       image: DecorationImage(
    //         image: AssetImage('assets/appBackgroundImg.jpg'),
    //         fit: BoxFit.cover,
    //       ),
    //     ),
    //     child: child,
    //   );
    // }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 158, 210, 159).withValues(alpha: 0.3),
                const Color.fromARGB(255, 210, 238, 212).withValues(alpha: 0.3),
                Colors.lightBlue.shade100.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
        SafeArea(child: child),
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
