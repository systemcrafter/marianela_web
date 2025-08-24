import 'package:flutter/material.dart';

/// Cabecera con degradé morado y ola inferior
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, this.height = 320});
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
          // Logo + Título
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  // Logo dentro de un círculo con relieve (sombra inferior)
                  Container(
                    width: 160, // tamaño del círculo
                    height: 160,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.25,
                          ), // sombra inferior
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_marianela.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Residencial Marianela Alajuela',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Decoraciones sutiles (círculos flotantes)
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
      color: Colors.white.withOpacity(.18),
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
