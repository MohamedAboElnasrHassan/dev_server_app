import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../base/app_base.dart';
import '../database/database_manager.dart';

/// مدير الإعدادات باستخدام SQLite
class SettingsManager extends BaseService {
  final DatabaseManager _databaseManager = Get.find<DatabaseManager>();
  
  // الإعدادات
  final theme = Rx<ThemeMode>(ThemeMode.system);
  final locale = Rx<Locale?>(null);
  final fontSize = 14.0.obs;
  final notificationsEnabled = true.obs;
  
  // مفاتيح الإعدادات
  final _themeKey = 'theme';
  final _localeKey = 'locale';
  final _fontSizeKey = 'font_size';
  final _notificationsKey = 'notifications_enabled';
  
  Future<SettingsManager> init() async {
    await initService();
    
    // تحميل الإعدادات من قاعدة البيانات
    await _loadSettings();
    
    return this;
  }
  
  /// تحميل الإعدادات من قاعدة البيانات
  Future<void> _loadSettings() async {
    // تحميل السمة
    final themeValue = await _getSetting(_themeKey);
    if (themeValue != null) {
      switch (themeValue) {
        case 'light':
          theme.value = ThemeMode.light;
          break;
        case 'dark':
          theme.value = ThemeMode.dark;
          break;
        default:
          theme.value = ThemeMode.system;
      }
    }
    
    // تحميل اللغة
    final localeValue = await _getSetting(_localeKey);
    if (localeValue != null) {
      final parts = localeValue.split('_');
      if (parts.length == 2) {
        locale.value = Locale(parts[0], parts[1]);
      } else {
        locale.value = Locale(localeValue);
      }
    }
    
    // تحميل حجم الخط
    final fontSizeValue = await _getSetting(_fontSizeKey);
    if (fontSizeValue != null) {
      fontSize.value = double.tryParse(fontSizeValue) ?? 14.0;
    }
    
    // تحميل إعدادات الإشعارات
    final notificationsValue = await _getSetting(_notificationsKey);
    if (notificationsValue != null) {
      notificationsEnabled.value = notificationsValue == 'true';
    }
  }
  
  /// الحصول على قيمة إعداد
  Future<String?> _getSetting(String key) async {
    final result = await _databaseManager.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }
  
  /// حفظ قيمة إعداد
  Future<void> _saveSetting(String key, String value) async {
    final existingSettings = await _databaseManager.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (existingSettings.isEmpty) {
      await _databaseManager.insert('settings', {
        'key': key,
        'value': value,
      });
    } else {
      await _databaseManager.update(
        'settings',
        {'value': value},
        where: 'key = ?',
        whereArgs: [key],
      );
    }
  }
  
  /// تغيير السمة
  Future<void> setTheme(ThemeMode mode) async {
    theme.value = mode;
    
    String themeValue;
    switch (mode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;
      case ThemeMode.dark:
        themeValue = 'dark';
        break;
      default:
        themeValue = 'system';
    }
    
    await _saveSetting(_themeKey, themeValue);
  }
  
  /// تغيير اللغة
  Future<void> setLocale(Locale newLocale) async {
    locale.value = newLocale;
    
    String localeValue = newLocale.languageCode;
    if (newLocale.countryCode != null) {
      localeValue += '_${newLocale.countryCode}';
    }
    
    await _saveSetting(_localeKey, localeValue);
    
    // تطبيق اللغة الجديدة
    Get.updateLocale(newLocale);
  }
  
  /// تغيير حجم الخط
  Future<void> setFontSize(double size) async {
    fontSize.value = size;
    await _saveSetting(_fontSizeKey, size.toString());
  }
  
  /// تغيير إعدادات الإشعارات
  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _saveSetting(_notificationsKey, enabled.toString());
  }
  
  /// إعادة تعيين الإعدادات إلى القيم الافتراضية
  Future<void> resetSettings() async {
    // حذف جميع الإعدادات
    await _databaseManager.delete('settings');
    
    // إعادة تعيين القيم
    theme.value = ThemeMode.system;
    locale.value = null;
    fontSize.value = 14.0;
    notificationsEnabled.value = true;
    
    // تطبيق اللغة الافتراضية
    Get.updateLocale(Get.deviceLocale ?? const Locale('en', 'US'));
  }
}
