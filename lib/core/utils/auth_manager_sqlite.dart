import 'package:get/get.dart';
import '../../app/data/models/user_model.dart';
import '../../app/data/repositories/user_repository_sqlite.dart';
import '../base/app_base.dart';
import '../logging/logger.dart';

/// مدير المصادقة باستخدام SQLite
class AuthManagerSQLite extends BaseService {
  final UserRepositorySQLite _userRepository = Get.find<UserRepositorySQLite>();
  final Logger _logger = Get.find<Logger>();

  final isLoggedIn = false.obs;
  final user = Rx<UserModel?>(null);
  final authLoading = false.obs;
  final authError = RxString('');

  Future<AuthManagerSQLite> init() async {
    await initService();
    return this;
  }

  /// تسجيل الدخول
  Future<bool> login(String email, String password) async {
    try {
      authLoading.value = true;
      authError.value = '';

      final authenticatedUser = await _userRepository.authenticate(email, password);
      
      if (authenticatedUser == null) {
        authError.value = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        authLoading.value = false;
        return false;
      }

      // تحديث البيانات
      user.value = authenticatedUser;
      isLoggedIn.value = true;

      authLoading.value = false;
      return true;
    } catch (e) {
      authLoading.value = false;
      authError.value = e.toString();
      _logger.error('Login error', error: e);
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      // مسح البيانات
      user.value = null;
      isLoggedIn.value = false;
    } catch (e) {
      _logger.error('Logout error', error: e);
    }
  }

  /// تسجيل مستخدم جديد
  Future<bool> register(String name, String email, String password) async {
    try {
      authLoading.value = true;
      authError.value = '';

      // التحقق من عدم وجود مستخدم بنفس البريد الإلكتروني
      final existingUser = await _userRepository.findByEmail(email);
      if (existingUser != null) {
        authError.value = 'البريد الإلكتروني مستخدم بالفعل';
        authLoading.value = false;
        return false;
      }

      // إنشاء مستخدم جديد
      final newUser = UserModel(
        name: name,
        email: email,
        password: password, // في الإنتاج، يجب تشفير كلمة المرور
        roles: ['user'],
      );

      // حفظ المستخدم في قاعدة البيانات
      final userId = await _userRepository.addUser(newUser);
      
      // الحصول على المستخدم المحفوظ
      final savedUser = await _userRepository.getById(userId);
      
      if (savedUser == null) {
        authError.value = 'حدث خطأ أثناء تسجيل المستخدم';
        authLoading.value = false;
        return false;
      }

      // تحديث البيانات
      user.value = savedUser;
      isLoggedIn.value = true;

      authLoading.value = false;
      return true;
    } catch (e) {
      authLoading.value = false;
      authError.value = e.toString();
      _logger.error('Register error', error: e);
      return false;
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      authLoading.value = true;
      authError.value = '';

      // التحقق من وجود مستخدم حالي
      if (user.value == null || user.value!.id == null) {
        authError.value = 'يجب تسجيل الدخول أولاً';
        authLoading.value = false;
        return false;
      }

      // تحديث المستخدم في قاعدة البيانات
      await _userRepository.updateUser(updatedUser);
      
      // تحديث البيانات
      user.value = updatedUser;

      authLoading.value = false;
      return true;
    } catch (e) {
      authLoading.value = false;
      authError.value = e.toString();
      _logger.error('Update profile error', error: e);
      return false;
    }
  }

  /// التحقق من وجود دور معين
  bool hasRole(String role) {
    return user.value?.hasRole(role) ?? false;
  }

  /// التحقق من وجود أي دور من مجموعة أدوار
  bool hasAnyRole(List<String> roles) {
    return user.value?.hasAnyRole(roles) ?? false;
  }

  /// الحصول على اسم المستخدم
  String get userName => user.value?.name ?? 'زائر';

  /// الحصول على بريد المستخدم
  String get userEmail => user.value?.email ?? '';

  /// الحصول على صورة المستخدم
  String? get userAvatar => user.value?.avatar;

  /// الحصول على معرف المستخدم
  int? get userId => user.value?.id;
}
