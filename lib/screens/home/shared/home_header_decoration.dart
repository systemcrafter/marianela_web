import 'package:flutter/material.dart';

/// Header angosto reutilizable para los HomeScreens.
/// Incluye fondo con ola, logo a la izquierda y texto opcional a la derecha.
/// Usa `contentTop` para subir/bajar el bloque (logo + texto) dentro del header.
class HomeHeaderDecoration extends StatelessWidget {
  final double height;
  final String? title;
  final double contentTop; // <- NUEVO: controla el padding superior del Row

  const HomeHeaderDecoration({
    super.key,
    this.height = 120,
    this.title,
    this.contentTop = 8, // sube el contenido (0..12 recomendado)
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo degradé con curva
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

          // Contenido: logo + texto (subido con top padding)
          Positioned.fill(
            child: Padding(
              // 👇 Ajuste principal para "subir" el contenido
              padding: EdgeInsets.only(
                top: contentTop, // antes era vertical: 10
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo con fondo blanco
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/logo_marianela.png",
                      height: height * 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Texto
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ClipPath para la ola inferior (ajustada para ola más alta)
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * .85);
    final firstControlPoint = Offset(size.width * .25, size.height * .95);
    final firstEndPoint = Offset(size.width * .5, size.height * .88);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    final secondControlPoint = Offset(size.width * .75, size.height * .82);
    final secondEndPoint = Offset(size.width, size.height * .90);
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
