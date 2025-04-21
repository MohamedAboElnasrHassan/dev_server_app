import 'package:get/get.dart';
import '../database/database_manager.dart';
import '../logging/logger.dart';
import '../network/api_manager.dart';
import '../network/connectivity_manager.dart';
import '../storage/storage_manager.dart';
import '../theme/theme_manager.dart';
import '../translations/language_manager.dart';
import '../utils/auth_manager.dart';
import '../utils/navigation_manager.dart';
import '../utils/settings_manager.dart';

/// تهيئة جميع الخدمات
class ServiceInitializer {
  /// تهيئة جميع الخدمات
  static Future<void> init() async {
    // تهيئة السجل
    await Get.putAsync(
      () => Logger(enableConsoleOutput: true, enableFileOutput: false).init(),
      permanent: true,
    );

    final logger = Get.find<Logger>();
    logger.info('Initializing services...');

    // تهيئة قاعدة البيانات
    final databaseManager = await DatabaseManager().init();
    Get.put(databaseManager, permanent: true);
    logger.info('Database initialized');

    // تهيئة التخزين
    final storageManager = await StorageManager().init();
    Get.put(storageManager, permanent: true);
    logger.info('Storage initialized');

    // تهيئة الاتصال
    await Get.putAsync(() => ConnectivityManager().init(), permanent: true);
    logger.info('Connectivity initialized');

    // تهيئة الشبكة
    await Get.putAsync(
      () =>
          ApiManager(
            baseUrl: 'https://api.example.com',
            defaultHeaders: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).init(),
      permanent: true,
    );
    logger.info('API initialized');

    // تهيئة الإعدادات
    final settingsManager = await SettingsManager().init();
    Get.put(settingsManager, permanent: true);
    logger.info('Settings initialized');

    // تهيئة الموضوع
    await Get.putAsync(() => ThemeManager().init(), permanent: true);
    logger.info('Theme initialized');

    // تهيئة اللغة
    await Get.putAsync(() => LanguageManager().init(), permanent: true);
    logger.info('Language initialized');

    // تهيئة المصادقة
    await Get.putAsync(() => AuthManager().init(), permanent: true);
    logger.info('Auth initialized');

    // تهيئة التنقل
    await Get.putAsync(() => NavigationManager().init(), permanent: true);
    logger.info('Navigation initialized');

    logger.info('All services initialized');
  }
}
