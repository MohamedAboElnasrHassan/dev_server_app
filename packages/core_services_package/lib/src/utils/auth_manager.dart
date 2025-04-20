import 'package:get/get.dart';
import '../base/base_service.dart';
import '../logging/logger.dart';
import '../storage/storage_manager.dart';

/// نموذج المستخدم الأساسي
class BaseUserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;

  BaseUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }

  factory BaseUserModel.fromMap(Map<String, dynamic> map) {
    return BaseUserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      avatar: map['avatar'],
    );
  }
}

/// مدير المصادقة الأساسي
class AuthManager extends BaseService {
  late final Logger _logger;
  late final StorageManager _storageManager;

  final isLoggedIn = false.obs;
  final user = Rx<BaseUserModel?>(null);
  final authLoading = false.obs;
  final authError = RxString('');

  Future<AuthManager> init() async {
    await initService();
    
    // الحصول على مدير السجلات والتخزين
    _logger = Get.find<Logger>();
    _storageManager = Get.find<StorageManager>();
    
    // التحقق من حالة تسجيل الدخول
    await _checkLoginStatus();
    
    return this;
  }

  /// التحقق من حالة تسجيل الدخول
  Future<void> _checkLoginStatus() async {
    try {
      final token = await _storageManager.read<String>('auth_token');
      final userData = await _storageManager.read<String>('user_data');
      
      if (token != null && userData != null) {
        // تحميل بيانات المستخدم
        // يمكن استخدام readObject هنا إذا كان متاحًا
        isLoggedIn.value = true;
        _logger.info('User is logged in');
      } else {
        isLoggedIn.value = false;
        user.value = null;
        _logger.info('User is not logged in');
      }
    } catch (e) {
      _logger.error('Error checking login status', error: e);
      isLoggedIn.value = false;
      user.value = null;
    }
  }

  /// تسجيل الدخول
  Future<bool> login(String email, String password) async {
    try {
      authLoading.value = true;
      authError.value = '';
      
      // هنا يمكن إضافة منطق تسجيل الدخول الفعلي
      // مثال: الاتصال بواجهة برمجة التطبيقات للمصادقة
      
      // محاكاة تسجيل الدخول الناجح
      await Future.delayed(const Duration(seconds: 1));
      
      if (email == 'test@example.com' && password == 'password') {
        // حفظ رمز المصادقة
        await _storageManager.write('auth_token', 'sample_token_123');
        
        // حفظ بيانات المستخدم
        final newUser = BaseUserModel(
          id: 1,
          name: 'Test User',
          email: email,
          avatar: null,
        );
        
        // يمكن استخدام writeObject هنا إذا كان متاحًا
        await _storageManager.write('user_data', newUser.toMap().toString());
        
        user.value = newUser;
        isLoggedIn.value = true;
        
        _logger.info('User logged in: ${newUser.email}');
        return true;
      } else {
        authError.value = 'Invalid email or password';
        _logger.warning('Login failed: Invalid credentials');
        return false;
      }
    } catch (e) {
      authError.value = e.toString();
      _logger.error('Login error', error: e);
      return false;
    } finally {
      authLoading.value = false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      // حذف بيانات المصادقة
      await _storageManager.remove('auth_token');
      await _storageManager.remove('user_data');
      
      isLoggedIn.value = false;
      user.value = null;
      
      _logger.info('User logged out');
    } catch (e) {
      _logger.error('Logout error', error: e);
    }
  }

  /// التحقق من صلاحية رمز المصادقة
  Future<bool> validateToken() async {
    try {
      final token = await _storageManager.read<String>('auth_token');
      
      if (token == null) {
        return false;
      }
      
      // هنا يمكن إضافة منطق التحقق من صلاحية الرمز
      // مثال: الاتصال بواجهة برمجة التطبيقات للتحقق من صلاحية الرمز
      
      // محاكاة التحقق الناجح
      return true;
    } catch (e) {
      _logger.error('Token validation error', error: e);
      return false;
    }
  }
}
