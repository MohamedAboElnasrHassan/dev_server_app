import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Clase base para crear vistas responsivas
/// Extiende esta clase para crear vistas que se adapten a diferentes tamaños de pantalla
class ResponsiveView extends GetResponsiveView {
  ResponsiveView({super.key});

  /// Construye la vista para dispositivos móviles (pantallas pequeñas)
  @override
  Widget? phone() => null;

  /// Construye la vista para tablets (pantallas medianas)
  @override
  Widget? tablet() => null;

  /// Construye la vista para escritorio (pantallas grandes)
  @override
  Widget? desktop() => null;

  @override
  Widget? builder() {
    return null;
  }
}
