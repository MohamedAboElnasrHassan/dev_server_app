import 'package:get/get.dart';
import '../../app/data/repositories/order_repository.dart';
import '../../app/data/repositories/product_repository.dart';
import '../../app/data/repositories/user_repository_sqlite.dart';
import '../database/database_manager.dart';
import '../logging/logger.dart';
import '../storage/storage_manager.dart';
import '../updates/update_manager.dart';
import '../utils/auth_manager_sqlite.dart';
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

    // المستودعات
    Get.put(UserRepositorySQLite(), permanent: true);
    Get.put(ProductRepository(), permanent: true);
    Get.put(OrderRepository(), permanent: true);

    // مدراء الخدمات
    final authManager = await AuthManagerSQLite().init();
    Get.put(authManager, permanent: true);

    final settingsManager = await SettingsManager().init();
    Get.put(settingsManager, permanent: true);

    // مدير التخزين (مطلوب لمدير التحديثات)
    final storageManager = await StorageManager().init();
    Get.put(storageManager, permanent: true);

    // مدير التحديثات
    final updateManager = await UpdateManager().init();
    Get.put(updateManager, permanent: true);
  }
}
