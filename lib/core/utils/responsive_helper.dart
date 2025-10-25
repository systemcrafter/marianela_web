// lib/core/utils/responsive_helper.dart
import 'dart:html' as html;
import 'package:flutter/material.dart';

/// Aplica configuraciones globales para evitar problemas de escala en dispositivos Samsung y otros Androids.
/// Se debe invocar desde main.dart antes de runApp().
class ResponsiveHelper {
  static void applyViewportFix() {
    // Forzar escala consistente en navegadores móviles (especialmente Samsung)
    html.document.head?.append(
      html.MetaElement()
        ..name = 'viewport'
        ..content =
            'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no',
    );
  }

  /// Envuelve el árbol de widgets para normalizar escalado de texto y medidas.
  static Widget buildWithFixedTextScale(BuildContext context, Widget? child) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: const TextScaler.linear(1.0), // desactiva zoom de texto
      ),
      child: child!,
    );
  }
}
