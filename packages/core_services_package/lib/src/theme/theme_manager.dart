import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../base/base_service.dart';
import '../storage/storage_manager.dart';

/// مدير الموضوع
class ThemeManager extends BaseService {
  late final StorageManager _storageManager;
  final _themeKey = 'app_theme';

  final isDarkMode = false.obs;
  final currentTheme = ThemeMode.system.obs;
  final primaryColor = Color(0xFF2196F3).obs; // Colors.blue
  final accentColor = Color(0xFF448AFF).obs; // Colors.blueAccent

  Future<ThemeManager> init() async {
    await initService();

    // الحصول على مدير التخزين
    _storageManager = Get.find<StorageManager>();

    // تحميل الموضوع من التخزين
    await _loadTheme();

    // الاستماع للتغييرات في الموضوع
    ever(currentTheme, _onThemeChanged);
    ever(isDarkMode, _onDarkModeChanged);

    return this;
  }

  /// تحميل الموضوع من التخزين
  Future<void> _loadTheme() async {
    final savedTheme = await _storageManager.read<String>(_themeKey);

    if (savedTheme?.isNotEmpty == true) {
      switch (savedTheme) {
        case 'light':
          currentTheme.value = ThemeMode.light;
          isDarkMode.value = false;
          break;
        case 'dark':
          currentTheme.value = ThemeMode.dark;
          isDarkMode.value = true;
          break;
        case 'system':
          currentTheme.value = ThemeMode.system;
          isDarkMode.value = Get.isPlatformDarkMode;
          break;
        default:
          currentTheme.value = ThemeMode.system;
          isDarkMode.value = Get.isPlatformDarkMode;
      }
    } else {
      currentTheme.value = ThemeMode.system;
      isDarkMode.value = Get.isPlatformDarkMode;
    }

    // تحميل الألوان المخصصة
    final savedPrimaryColor = await _storageManager.read<int>('primary_color');
    if (savedPrimaryColor != null) {
      primaryColor.value = Color(savedPrimaryColor);
    }

    final savedAccentColor = await _storageManager.read<int>('accent_color');
    if (savedAccentColor != null) {
      accentColor.value = Color(savedAccentColor);
    }
  }

  /// معالجة تغيير الموضوع
  void _onThemeChanged(ThemeMode mode) {
    Get.changeThemeMode(mode);

    switch (mode) {
      case ThemeMode.light:
        _storageManager.write(_themeKey, 'light');
        break;
      case ThemeMode.dark:
        _storageManager.write(_themeKey, 'dark');
        break;
      case ThemeMode.system:
        _storageManager.write(_themeKey, 'system');
        break;
    }
  }

  /// معالجة تغيير الوضع الداكن
  void _onDarkModeChanged(bool isDark) {
    if (currentTheme.value != ThemeMode.system) {
      currentTheme.value = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// تبديل الموضوع بين الفاتح والداكن
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    currentTheme.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  }

  /// تعيين الموضوع
  void setTheme(ThemeMode mode) {
    currentTheme.value = mode;
    isDarkMode.value =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system && Get.isPlatformDarkMode);
  }

  /// تعيين اللون الأساسي
  void setPrimaryColor(Color color) {
    primaryColor.value = color;
    _storageManager.write(
      'primary_color',
      '${color.r.round().toRadixString(16).padLeft(2, '0')}${color.g.round().toRadixString(16).padLeft(2, '0')}${color.b.round().toRadixString(16).padLeft(2, '0')}',
    );
    _updateTheme();
  }

  /// تعيين لون التأكيد
  void setAccentColor(Color color) {
    accentColor.value = color;
    _storageManager.write(
      'accent_color',
      '${color.r.round().toRadixString(16).padLeft(2, '0')}${color.g.round().toRadixString(16).padLeft(2, '0')}${color.b.round().toRadixString(16).padLeft(2, '0')}',
    );
    _updateTheme();
  }

  /// تحديث الموضوع
  void _updateTheme() {
    // يمكن تحديث الموضوع هنا إذا كان هناك حاجة لذلك
    Get.forceAppUpdate();
  }

  /// الحصول على الموضوع الفاتح
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor.value,
      colorScheme: ColorScheme.light(
        primary: primaryColor.value,
        secondary: accentColor.value,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
        ),
      ),
      // يمكن إضافة المزيد من تخصيصات الموضوع هنا
    );
  }

  /// الحصول على الموضوع الداكن
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor.value,
      colorScheme: ColorScheme.dark(
        primary: primaryColor.value,
        secondary: accentColor.value,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
        ),
      ),
      // يمكن إضافة المزيد من تخصيصات الموضوع هنا
    );
  }

  /// الحصول على الموضوع الحالي
  ThemeData get theme {
    return isDarkMode.value ? getDarkTheme() : getLightTheme();
  }
}
