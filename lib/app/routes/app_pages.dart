import 'package:get/get.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/persistent_counter_view.dart';
import '../modules/home/views/responsive_home_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/updates/bindings/update_binding.dart';
import '../modules/updates/views/update_view.dart';
import 'app_routes.dart';
import 'middleware/admin_middleware.dart';
import 'middleware/auth_middleware.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.login, // استخدام الاسم الجديد بنمط lowerCamelCase
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.home, // استخدام الاسم الجديد بنمط lowerCamelCase
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.settings, // استخدام الاسم الجديد بنمط lowerCamelCase
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.admin, // استخدام الاسم الجديد بنمط lowerCamelCase
      page: () => const AdminView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
    GetPage(
      name: Routes.persistentCounter, // استخدام الاسم الجديد بنمط lowerCamelCase
      page: () => const PersistentCounterView(),
      binding: HomeBinding(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: Routes.responsiveHome, // استخدام الاسم الجديد بنمط lowerCamelCase
      page: () => ResponsiveHomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.update,
      page: () => const UpdateView(),
      binding: UpdateBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
