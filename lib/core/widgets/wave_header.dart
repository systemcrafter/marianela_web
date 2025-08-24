import 'package:flutter/material.dart';

class WaveHeader extends StatelessWidget {
  const WaveHeader({super.key, this.height = 220});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo degradé con ola
          Positioned.fill(
            child: ClipPath(
              clipper: _BottomWaveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7A6CF7), // morado 1
                      Color(0xFF9B59F6), // morado 2
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Burbujas decorativas (igual que en LoginHeader)
          Positioned(top: 40, left: 28, child: _softCircle(26)),
          Positioned(top: 96, right: 36, child: _softCircle(18)),
        ],
      ),
    );
  }

  Widget _softCircle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .18), // antes withOpacity
      shape: BoxShape.circle,
    ),
  );
}

/// Trazo de la ola inferior
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * .72);
    final firstControlPoint = Offset(size.width * .25, size.height * .82);
    final firstEndPoint = Offset(size.width * .5, size.height * .76);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    final secondControlPoint = Offset(size.width * .75, size.height * .70);
    final secondEndPoint = Offset(size.width, size.height * .78);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
