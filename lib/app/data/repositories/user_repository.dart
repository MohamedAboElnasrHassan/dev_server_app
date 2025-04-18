import 'dart:async';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class UserRepository {
  final UserProvider _userProvider = Get.find<UserProvider>();

  Future<List<UserModel>> getUsers() async {
    final response = await _userProvider.getUsers();
    if (response.hasError) {
      throw Exception('Error al obtener usuarios: ${response.statusText}');
    }
    return response.body ?? [];
  }

  Future<UserModel> getUser(int id) async {
    final response = await _userProvider.getUser(id);
    if (response.hasError) {
      throw Exception('Error al obtener usuario: ${response.statusText}');
    }
    return response.body!;
  }

  Future<UserModel> createUser(UserModel user) async {
    final response = await _userProvider.createUser(user);
    if (response.hasError) {
      throw Exception('Error al crear usuario: ${response.statusText}');
    }
    return response.body!;
  }

  Future<UserModel> updateUser(UserModel user) async {
    final response = await _userProvider.updateUser(user);
    if (response.hasError) {
      throw Exception('Error al actualizar usuario: ${response.statusText}');
    }
    return response.body!;
  }

  Future<void> deleteUser(int id) async {
    final response = await _userProvider.deleteUser(id);
    if (response.hasError) {
      throw Exception('Error al eliminar usuario: ${response.statusText}');
    }
  }

  // Ejemplo de uso de WebSocket
  Stream<dynamic> getUserUpdates() {
    final socket = _userProvider.userSocket();
    // Crear un stream a partir del socket
    final controller = StreamController<dynamic>();

    // Escuchar los mensajes del socket y enviarlos al stream
    socket.onMessage((data) {
      controller.add(data);
    });

    // Cerrar el controller cuando se cierre el stream
    controller.onCancel = () {
      socket.close();
      controller.close();
    };

    return controller.stream;
  }
}
