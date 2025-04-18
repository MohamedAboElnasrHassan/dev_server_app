import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../base/app_base.dart';
import '../storage/storage_manager.dart';

/// مدير اللغة
class LanguageManager extends BaseService {
  final StorageManager _storageManager = Get.find<StorageManager>();

  final currentLocale = Rx<Locale?>(null);
  final currentLanguageCode = 'en'.obs;
  final currentCountryCode = 'US'.obs;

  Future<LanguageManager> init() async {
    await initService();

    // تحميل اللغة من التخزين
    await _loadLocale();

    // الاستماع للتغييرات في اللغة
    ever(currentLocale, _onLocaleChanged);

    return this;
  }

  /// تحميل اللغة من التخزين
  Future<void> _loadLocale() async {
    final savedLanguageCode = await _storageManager.read<String>('language_code');
    final savedCountryCode = await _storageManager.read<String>('country_code');

    if (savedLanguageCode?.isNotEmpty == true && savedCountryCode?.isNotEmpty == true) {
      currentLanguageCode.value = savedLanguageCode!;
      currentCountryCode.value = savedCountryCode!;
      currentLocale.value = Locale(savedLanguageCode, savedCountryCode);
    } else {
      // استخدام لغة النظام أو اللغة الافتراضية
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null && isLanguageSupported(deviceLocale.languageCode)) {
        currentLanguageCode.value = deviceLocale.languageCode;
        currentCountryCode.value = deviceLocale.countryCode ?? 'US';
        currentLocale.value = deviceLocale;
      } else {
        // اللغة الافتراضية
        currentLanguageCode.value = 'en';
        currentCountryCode.value = 'US';
        currentLocale.value = const Locale('en', 'US');
      }
    }
  }

  /// معالجة تغيير اللغة
  void _onLocaleChanged(Locale? locale) {
    if (locale != null) {
      Get.updateLocale(locale);
      // استدعاء دالة حفظ اللغة بدون انتظار النتيجة
      _saveLocale(locale.languageCode, locale.countryCode ?? 'US');
    }
  }

  /// حفظ اللغة في التخزين
  Future<void> _saveLocale(String languageCode, String countryCode) async {
    await _storageManager.write('language_code', languageCode);
    await _storageManager.write('country_code', countryCode);
  }

  /// تغيير اللغة
  void changeLocale(String languageCode, String countryCode) {
    if (isLanguageSupported(languageCode)) {
      currentLanguageCode.value = languageCode;
      currentCountryCode.value = countryCode;
      currentLocale.value = Locale(languageCode, countryCode);
    }
  }

  /// التحقق من دعم اللغة
  bool isLanguageSupported(String languageCode) {
    return availableLanguages.any((lang) => lang['code'] == languageCode);
  }

  /// الحصول على اسم اللغة الحالية
  String get currentLanguageName {
    final lang = availableLanguages.firstWhere(
      (lang) => lang['code'] == currentLanguageCode.value,
      orElse: () => availableLanguages.first,
    );

    return lang['name'] ?? 'English';
  }

  /// الحصول على اللغة الحالية
  Locale? get locale => currentLocale.value;

  /// الحصول على اللغات المتاحة
  List<Map<String, String>> get availableLanguages => [
    {'code': 'en', 'country': 'US', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'country': 'SA', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'es', 'country': 'ES', 'name': 'Español', 'flag': '🇪🇸'},
    // يمكن إضافة المزيد من اللغات هنا
  ];

  /// التحقق من اتجاه اللغة الحالية
  bool get isRtl {
    return currentLanguageCode.value == 'ar';
  }

  /// الحصول على اتجاه النص الحالي
  TextDirection get textDirection {
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }
}
