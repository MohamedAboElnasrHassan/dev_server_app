import 'package:get/get.dart';
import '../../../../core/utils/auth_manager_sqlite.dart';

class AuthController extends GetxController {
  final AuthManagerSQLite _authManager = Get.find<AuthManagerSQLite>();

  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void updateEmail(String value) => email.value = value;
  void updatePassword(String value) => password.value = value;

  Future<bool> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      errorMessage.value = 'Por favor, complete todos los campos';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authManager.login(email.value, password.value);
      isLoading.value = false;

      if (result) {
        Get.offAllNamed('/');
        return true;
      } else {
        errorMessage.value = 'Credenciales inválidas';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error al iniciar sesión: $e';
      return false;
    }
  }

  Future<void> logout() async {
    await _authManager.logout();
    Get.offAllNamed('/login');
  }
}
