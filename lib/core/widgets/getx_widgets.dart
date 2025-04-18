// import 'package:flutter/material.dart'; // Not needed as it's imported via Get
import 'package:get/get.dart';

/// Widget base para vistas que utilizan un controlador GetX
///
/// Ejemplo de uso:
/// ```dart
/// class HomeView extends BaseView<HomeController> {
///   const HomeView({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Home')),
///       body: Center(
///         child: Obx(() => Text('Count: ${controller.count}')),
///       ),
///     );
///   }
/// }
/// ```
abstract class BaseView<T> extends GetView<T> {
  const BaseView({super.key});
}

/// Widget que mantiene el estado del controlador
///
/// Útil cuando necesitas mantener el estado incluso cuando el widget se reconstruye
///
/// Ejemplo de uso:
/// ```dart
/// class PersistentView extends StatefulWidget {
///   @override
///   _PersistentViewState createState() => _PersistentViewState();
/// }
///
/// class _PersistentViewState extends StatefulWidget<PersistentView> {
///   final controller = Get.find<MyController>();
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Persistent View')),
///       body: Center(
///         child: Text('This view keeps its controller state'),
///       ),
///     );
///   }
/// }
/// ```
abstract class StatefulWidget<T extends GetxController> extends GetWidget<T> {
  const StatefulWidget({super.key});
}

/// Servicio que permanece en memoria durante toda la aplicación
///
/// Ejemplo de uso:
/// ```dart
/// class ApiService extends BaseService {
///   final dio = Dio();
///
///   Future<Response> getUsers() async {
///     return await dio.get('/users');
///   }
///
///   @override
///   void onInit() {
///     super.onInit();
///     // Inicializar el servicio
///     dio.options.baseUrl = 'https://api.example.com';
///   }
/// }
///
/// // Para inicializar:
/// Get.put(ApiService(), permanent: true);
/// ```
abstract class BaseService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    printInfo(info: '$runtimeType initialized');
  }

  @override
  void onClose() {
    printInfo(info: '$runtimeType closed');
    super.onClose();
  }
}
