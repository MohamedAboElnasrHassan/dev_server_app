import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_services_package/core_services_package.dart';

/// هذا الملف هو للاختبار فقط
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الخدمات
  await ServiceInitializer.init();

  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على مديري الموضوع واللغة والمصادقة والتنقل
    final themeManager = Get.find<ThemeManager>();
    final languageManager = Get.find<LanguageManager>();
    // final authManager = Get.find<AuthManager>();
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
      home: const TestPage(),
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

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();
    final languageManager = Get.find<LanguageManager>();
    final connectivityManager = Get.find<ConnectivityManager>();
    final logger = Get.find<Logger>();

    logger.info('Test page built');

    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'welcome'.tr,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'current_language: ${languageManager.currentLanguageCode.value}'.tr': ${languageManager.currentLanguageCode.value}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'connection_status: ${connectivityManager.hasConnection ? "connected".tr : "disconnected".tr}'.tr': ${connectivityManager.hasConnection ? 'connected'.tr : 'disconnected'.tr}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                themeManager.toggleTheme();
              },
              child: Text('toggle_theme'.tr),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (languageManager.currentLanguageCode.value == 'en') {
                  languageManager.changeLocale('ar', 'SA');
                } else {
                  languageManager.changeLocale('en', 'US');
                }
              },
              child: Text('change_language'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
