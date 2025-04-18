/// Clase de ayuda para validaciones
class ValidationHelper {
  /// Valida un email
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
  
  /// Valida una contraseña (mínimo 6 caracteres)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
  
  /// Valida un nombre (no vacío)
  static bool isValidName(String name) {
    return name.trim().isNotEmpty;
  }
  
  /// Valida un número de teléfono
  static bool isValidPhone(String phone) {
    final phoneRegExp = RegExp(r'^\d{10}$');
    return phoneRegExp.hasMatch(phone);
  }
  
  /// Valida que dos contraseñas coincidan
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
