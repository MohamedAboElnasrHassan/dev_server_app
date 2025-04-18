import 'package:get/get.dart';
import 'navigation_manager.dart';
import '../di/dependency_injection.dart';
import '../logging/logger.dart';
import '../network/api_manager.dart';
import '../network/connectivity_manager.dart';
import '../notifications/notification_manager.dart';
import '../theme/theme_manager.dart';
import '../translations/language_manager.dart';
import '../updates/update_manager.dart';
import '../../app/modules/updates/views/update_dialog.dart';

/// تهيئة جميع الخدمات
class ServiceInitializer {
  /// تهيئة جميع الخدمات
  static Future<void> init() async {
    // تهيئة السجل
    await Get.putAsync(() => Logger(
      enableConsoleOutput: true,
      enableFileOutput: false,
    ).init(), permanent: true);

    final logger = Get.find<Logger>();
    logger.info('Initializing services...');

    // تهيئة قاعدة البيانات والتبعيات
    await DependencyInjection.init();

    // تهيئة الاتصال
    await Get.putAsync(() => ConnectivityManager().init(), permanent: true);

    // تهيئة الشبكة
    await Get.putAsync(() => ApiManager(
      baseUrl: 'https://api.example.com',
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).init(), permanent: true);

    // تهيئة الإشعارات
    await Get.putAsync(() => NotificationManager().init(), permanent: true);

    // تم تهيئة التخزين مسبقًا في DependencyInjection

    // تهيئة الموضوع
    await Get.putAsync(() => ThemeManager().init(), permanent: true);

    // تهيئة اللغة
    await Get.putAsync(() => LanguageManager().init(), permanent: true);

    // تهيئة التنقل
    await Get.putAsync(() => NavigationManager().init(), permanent: true);

    logger.info('All services initialized');

    // التحقق من وجود تحديثات
    _checkForUpdates();
  }

  /// التحقق من وجود تحديثات
  static Future<void> _checkForUpdates() async {
    try {
      // التحقق من وجود مدير التحديثات
      if (Get.isRegistered<UpdateManager>()) {
        final updateManager = Get.find<UpdateManager>();

        // التحقق من وجود تحديثات
        final hasUpdates = await updateManager.checkForUpdates();

        // إذا كان هناك تحديث، عرض حوار التحديث
        if (hasUpdates) {
          // الانتظار قليلاً للتأكد من أن التطبيق جاهز
          await Future.delayed(const Duration(seconds: 2));

          // عرض حوار التحديث
          UpdateDialog.show(required: updateManager.updateRequired.value);
        }
      }
    } catch (e) {
      // تجاهل الأخطاء في التحقق من التحديثات
      final logger = Get.find<Logger>();
      logger.error('Error checking for updates', error: e);
    }
  }
}
