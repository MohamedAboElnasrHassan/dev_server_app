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

/// مدير التبعيات
class DependencyInjection {
  /// تهيئة التبعيات
  static Future<void> init() async {
    // الخدمات الأساسية
    final logger = Logger();
    Get.put(logger, permanent: true);

    // قاعدة البيانات
    final databaseManager = await DatabaseManager().init();
    Get.put(databaseManager, permanent: true);

    // التخزين
    final storageManager = await StorageManager().init();
    Get.put(storageManager, permanent: true);

    // الاتصال
    final connectivityManager = await ConnectivityManager().init();
    Get.put(connectivityManager, permanent: true);

    // الشبكة
    final apiManager =
        await ApiManager(
          baseUrl: 'https://api.example.com',
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).init();
    Get.put(apiManager, permanent: true);

    // الإعدادات
    final settingsManager = await SettingsManager().init();
    Get.put(settingsManager, permanent: true);

    // الموضوع
    final themeManager = await ThemeManager().init();
    Get.put(themeManager, permanent: true);

    // اللغة
    final languageManager = await LanguageManager().init();
    Get.put(languageManager, permanent: true);

    // المصادقة
    final authManager = await AuthManager().init();
    Get.put(authManager, permanent: true);

    // التنقل
    final navigationManager = await NavigationManager().init();
    Get.put(navigationManager, permanent: true);
  }
}
