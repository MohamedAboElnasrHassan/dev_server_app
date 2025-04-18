import 'package:get/get.dart';
import '../data/providers/api_provider.dart';
import '../data/providers/user_provider.dart';
import '../../core/utils/auth_manager_sqlite.dart';
import '../../core/translations/language_manager.dart';
import '../../core/theme/theme_manager.dart';

/// Binding global de la aplicación
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // الخدمات
    Get.put(ThemeManager(), permanent: true);
    Get.put(LanguageManager(), permanent: true);
    Get.put(AuthManagerSQLite(), permanent: true);

    // Proveedores
    Get.put(ApiProvider(), permanent: true);
    Get.lazyPut(() => UserProvider());
  }
}
