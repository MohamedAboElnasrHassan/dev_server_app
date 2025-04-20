# دليل الترحيل إلى حزمة الخدمات الأساسية

هذا الدليل يشرح كيفية ترحيل التطبيق من استخدام الخدمات الأساسية المضمنة في مجلد `lib/core/` إلى استخدام حزمة `core_services_package` الجديدة.

## الخطوات

### 1. تحديث التبعيات

أضف حزمة `core_services_package` إلى ملف `pubspec.yaml`:

```yaml
dependencies:
  core_services_package:
    path: ../../packages/core_services_package
```

### 2. تحديث الاستيرادات

استبدل الاستيرادات القديمة بالاستيراد الجديد:

```dart
// قبل
import 'core/theme/theme_manager.dart';
import 'core/translations/language_manager.dart';
import 'core/utils/auth_manager_sqlite.dart';
import 'core/utils/navigation_manager.dart';
import 'core/utils/service_initializer.dart';

// بعد
import 'package:core_services_package/core_services_package.dart';
```

### 3. تحديث استخدام AuthManager

استبدل `AuthManagerSQLite` بـ `AuthManager`:

```dart
// قبل
final authManager = Get.find<AuthManagerSQLite>();

// بعد
final authManager = Get.find<AuthManager>();
```

### 4. تحديث استخدام الترجمات

استخدم `AppTranslations` من الحزمة الجديدة:

```dart
// قبل
import 'core/translations/app_translations.dart';

// بعد
// لا حاجة لاستيراد إضافي، فهو مضمن في core_services_package
```

### 5. اختبار التطبيق

قم بتشغيل التطبيق للتأكد من أن كل شيء يعمل بشكل صحيح. يمكنك استخدام ملف `test_migration.dart` للاختبار.

## الخدمات المتاحة

الحزمة الجديدة توفر الخدمات التالية:

### الخدمات الأساسية
- `Logger`: إدارة السجلات
- `ConnectivityManager`: إدارة الاتصال بالإنترنت
- `ApiManager`: إدارة طلبات الشبكة
- `StorageManager`: إدارة التخزين المحلي
- `DatabaseManager`: إدارة قاعدة البيانات
- `ThemeManager`: إدارة السمات
- `LanguageManager`: إدارة اللغات
- `AuthManager`: إدارة المصادقة
- `NavigationManager`: إدارة التنقل
- `SettingsManager`: إدارة الإعدادات
- `ServiceInitializer`: تهيئة الخدمات
- `DependencyInjection`: حقن التبعيات
- `CustomStateManager`: إدارة الحالة المخصصة

### الخدمات الإضافية
- `FormManager`: إدارة النماذج
- `NotificationManager`: إدارة الإشعارات
- `UpdateManager`: إدارة التحديثات
- `VersionInfo`: نموذج معلومات الإصدار

### القيم والثوابت
- `AppColors`: ألوان التطبيق

### المكونات المرئية
- `CustomButton`: زر مخصص
- `CustomCard`: بطاقة مخصصة
- `CustomDialog`: حوار مخصص
- `CustomTextField`: حقل نص مخصص
- `ResponsiveView`: عرض متجاوب

## ملاحظات

- بعد التأكد من أن كل شيء يعمل بشكل صحيح، يمكنك حذف مجلد `lib/core/` من التطبيق الرئيسي.
- إذا كنت بحاجة إلى تخصيص أي من الخدمات، يمكنك إنشاء فئة فرعية تمتد من الفئة الأساسية في الحزمة.
