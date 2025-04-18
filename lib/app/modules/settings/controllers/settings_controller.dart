import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/translations/language_manager.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/updates/update_manager.dart';
import '../../../../core/utils/settings_manager.dart';

class SettingsController extends GetxController {
  final ThemeManager themeManager = Get.find<ThemeManager>();
  final LanguageManager languageManager = Get.find<LanguageManager>();
  final SettingsManager _settingsManager = Get.find<SettingsManager>();
  final UpdateManager updateManager = Get.find<UpdateManager>();

  final isDarkMode = false.obs;
  final currentLanguage = 'Arabic'.obs;
  final themeMode = ThemeMode.system.obs;
  final language = 'ar'.obs;
  final fontSize = 14.0.obs;
  final notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    // تحميل الإعدادات الحالية
    isDarkMode.value = themeManager.isDarkMode.value;
    currentLanguage.value = languageManager.currentLanguageName;

    themeMode.value = _settingsManager.theme.value;
    fontSize.value = _settingsManager.fontSize.value;
    notificationsEnabled.value = _settingsManager.notificationsEnabled.value;

    // تحديد اللغة الحالية
    if (_settingsManager.locale.value != null) {
      language.value = _settingsManager.locale.value!.languageCode;
    } else {
      language.value = Get.deviceLocale?.languageCode ?? 'ar';
    }
  }

  void toggleTheme() {
    themeManager.toggleTheme();
    isDarkMode.value = themeManager.isDarkMode.value;
  }

  /// تغيير اللغة باستخدام مدير اللغة القديم
  void changeLanguageOld(String languageCode, String countryCode) {
    languageManager.changeLocale(languageCode, countryCode);
    currentLanguage.value = languageManager.currentLanguageName;
  }

  /// تغيير السمة
  void changeTheme(ThemeMode? mode) {
    if (mode != null) {
      themeMode.value = mode;
      _settingsManager.setTheme(mode);
    }
  }

  /// تغيير اللغة
  void changeLanguage(String? languageCode) {
    if (languageCode != null) {
      language.value = languageCode;

      Locale locale;
      switch (languageCode) {
        case 'ar':
          locale = const Locale('ar', 'SA');
          break;
        case 'en':
          locale = const Locale('en', 'US');
          break;
        default:
          locale = const Locale('ar', 'SA');
      }

      _settingsManager.setLocale(locale);
    }
  }

  /// تغيير حجم الخط
  void changeFontSize(double size) {
    fontSize.value = size;
    _settingsManager.setFontSize(size);
  }

  /// تفعيل/تعطيل الإشعارات
  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
    _settingsManager.setNotificationsEnabled(enabled);
  }

  /// التحقق من وجود تحديثات
  Future<void> checkForUpdates() async {
    final hasUpdates = await updateManager.checkForUpdates(force: true);

    if (hasUpdates) {
      Get.toNamed('/update');
    } else {
      Get.snackbar(
        'no_updates'.tr,
        'you_have_latest_version'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// إعادة تعيين الإعدادات
  void resetSettings() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_reset'.tr),
        content: Text('reset_settings_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performReset();
            },
            child: Text('reset'.tr),
          ),
        ],
      ),
    );
  }

  /// تنفيذ إعادة تعيين الإعدادات
  void _performReset() async {
    await _settingsManager.resetSettings();

    // تحديث القيم المحلية
    themeMode.value = ThemeMode.system;
    language.value = Get.deviceLocale?.languageCode ?? 'ar';
    fontSize.value = 14.0;
    notificationsEnabled.value = true;

    Get.snackbar(
      'success'.tr,
      'settings_reset_success'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
