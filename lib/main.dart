import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/theme_manager.dart';
import 'core/translations/app_translations.dart';
import 'core/translations/language_manager.dart';
import 'core/utils/auth_manager_sqlite.dart';
import 'core/utils/navigation_manager.dart';
import 'core/utils/service_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة جميع الخدمات
  await ServiceInitializer.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على مديري الموضوع واللغة والمصادقة والتنقل
    final themeManager = Get.find<ThemeManager>();
    final languageManager = Get.find<LanguageManager>();
    final authManager = Get.find<AuthManagerSQLite>();
    final navigationManager = Get.find<NavigationManager>();

    return GetMaterialApp(
      title: 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      theme: themeManager.getLightTheme(),
      darkTheme: themeManager.getDarkTheme(),
      themeMode: themeManager.currentTheme.value,
      locale: languageManager.locale,
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
      initialRoute: authManager.isLoggedIn.value ? Routes.HOME : Routes.LOGIN,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      onGenerateRoute: (settings) {
        // تحديث المسار الحالي في مدير التنقل
        navigationManager.currentRoute.value = settings.name ?? '';
        return null;
      },
      builder: (context, child) {
        // تطبيق اتجاه النص بناءً على اللغة
        return Directionality(
          textDirection: languageManager.textDirection,
          child: child!,
        );
      },
    );
  }
}
