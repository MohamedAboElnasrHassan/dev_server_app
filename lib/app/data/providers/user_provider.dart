import 'package:get/get.dart';
import '../../../core/storage/storage_manager.dart';
import '../models/user_model.dart';

class UserProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://api.example.com/';

    // Añadir decodificador por defecto
    httpClient.defaultDecoder = (map) {
      if (map is Map<String, dynamic>) return UserModel.fromJson(map);
      if (map is List) return map.map((item) => UserModel.fromJson(item)).toList();
    };

    // Añadir encabezados por defecto
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';

      // Añadir token de autenticación si existe
      // استخدام الدالة الغير متزامنة للحصول على الرمز المميز
      Get.find<StorageManager>().read<String>('auth_token').then((token) {
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      });

      return request;
    });
  }

  Future<Response<List<UserModel>>> getUsers() => get<List<UserModel>>('users');

  Future<Response<UserModel>> getUser(int id) => get<UserModel>('users/$id');

  Future<Response<UserModel>> createUser(UserModel user) =>
      post<UserModel>('users', user.toJson());

  Future<Response<UserModel>> updateUser(UserModel user) =>
      put<UserModel>('users/${user.id}', user.toJson());

  Future<Response> deleteUser(int id) => delete('users/$id');

  // Ejemplo de uso de WebSocket
  GetSocket userSocket() {
    return socket('users');
  }
}
