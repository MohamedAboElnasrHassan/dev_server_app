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

/// Ejemplo de uso:
/// ```dart
/// class MyResponsiveView extends ResponsiveView {
///   MyResponsiveView({Key? key}) : super(key: key);
///
///   @override
///   Widget? phone() {
///     return Container(
///       color: Colors.red,
///       child: Center(child: Text('Phone View')),
///     );
///   }
///
///   @override
///   Widget? tablet() {
///     return Container(
///       color: Colors.green,
///       child: Center(child: Text('Tablet View')),
///     );
///   }
///
///   @override
///   Widget? desktop() {
///     return Container(
///       color: Colors.blue,
///       child: Center(child: Text('Desktop View')),
///     );
///   }
/// }
/// ```
