import 'package:get/get.dart';

/// Proveedor de API utilizando GetConnect
class ApiProvider extends GetConnect {
  @override
  void onInit() {
    // Configuración base de la API
    httpClient.baseUrl = 'https://api.example.com';

    // Tiempo de espera para las solicitudes
    httpClient.timeout = const Duration(seconds: 30);

    // Añadir encabezados por defecto
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      return request;
    });

    // Interceptor para manejar respuestas
    httpClient.addResponseModifier<dynamic>((request, response) {
      printInfo(info: 'Status Code: ${response.statusCode}');
      printInfo(info: 'Response: ${response.bodyString}');
      return response;
    });

    // Interceptor para manejar errores
    httpClient.addResponseModifier<dynamic>((request, response) {
      if (response.statusCode != 200) {
        printError(info: 'Error: ${response.statusCode}');
        printError(info: 'Error Body: ${response.bodyString}');
      }
      return response;
    });
  }

  // Ejemplo de método GET
  Future<Response> getUsers() => get('/users');

  // Ejemplo de método POST
  Future<Response> createUser(Map<String, dynamic> data) => post('/users', data);

  // Ejemplo de método PUT
  Future<Response> updateUser(int id, Map<String, dynamic> data) => put('/users/$id', data);

  // Ejemplo de método DELETE
  Future<Response> deleteUser(int id) => delete('/users/$id');

  // Ejemplo de subida de archivos
  Future<Response> uploadFile(List<int> file) {
    final form = FormData({
      'file': MultipartFile(file, filename: 'avatar.png'),
    });
    return post('/upload', form);
  }

  // Ejemplo de conexión WebSocket
  GetSocket createUserSocket() {
    return socket('wss://api.example.com/users');
  }
}
