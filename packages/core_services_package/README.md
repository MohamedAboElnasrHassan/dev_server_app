# Core Services Package 🛠️

حزمة الخدمات الأساسية لتطبيق Dev Server. توفر هذه الحزمة مجموعة من الخدمات الأساسية مثل إدارة الاتصال، إدارة الشبكة، إدارة التخزين، إدارة قاعدة البيانات، وغيرها.

للاطلاع على دليل الترحيل من المجلد `lib/core/` إلى هذه الحزمة، راجع [MIGRATION.md](MIGRATION.md).

## المميزات 💪

- 🔌 إدارة الاتصال بالإنترنت
- 🌐 إدارة طلبات الشبكة
- 💾 إدارة التخزين المحلي
- 🗄️ إدارة قاعدة البيانات
- 📝 إدارة السجلات
- 🔐 إدارة المصادقة
- ⚙️ إدارة الإعدادات
- 🌍 إدارة اللغات
- 🎨 إدارة السمات
- 📢 إدارة الإشعارات
- 📰 إدارة التحديثات
- 📋 إدارة النماذج
- 👽 مكونات واجهة مستخدم مخصصة

## الاستخدام 💻

```dart
import 'package:core_services_package/core_services_package.dart';

void main() async {
  // تهيئة الخدمات
  await ServiceInitializer.init();

  // استخدام مدير الاتصال
  final connectivityManager = Get.find<ConnectivityManager>();
  if (connectivityManager.hasConnection) {
    print('متصل بالإنترنت');
  }

  // استخدام مدير الشبكة
  final apiManager = Get.find<ApiManager>();
  final response = await apiManager.get('/users');

  // استخدام مدير التخزين
  final storageManager = Get.find<StorageManager>();
  await storageManager.write('key', 'value');

  // استخدام مدير قاعدة البيانات
  final databaseManager = Get.find<DatabaseManager>();
  final db = await databaseManager.database;

  // استخدام مدير السجلات
  final logger = Get.find<Logger>();
  logger.info('تم تهيئة الخدمات بنجاح');
}
```

## الخدمات المتاحة 📋

### إدارة الاتصال

- `ConnectivityManager`: إدارة الاتصال بالإنترنت
- `ApiManager`: إدارة طلبات الشبكة

### إدارة التخزين

- `StorageManager`: إدارة التخزين المحلي
- `DatabaseManager`: إدارة قاعدة البيانات

### إدارة الخدمات

- `Logger`: إدارة السجلات
- `AuthManager`: إدارة المصادقة
- `SettingsManager`: إدارة الإعدادات
- `LanguageManager`: إدارة اللغات
- `ThemeManager`: إدارة السمات
- `NotificationManager`: إدارة الإشعارات
- `UpdateManager`: إدارة التحديثات
- `FormManager`: إدارة النماذج

### المكونات المرئية

- `CustomButton`: زر مخصص
- `CustomCard`: بطاقة مخصصة
- `CustomDialog`: حوار مخصص
- `CustomTextField`: حقل نص مخصص
- `ResponsiveView`: عرض متجاوب

## المتطلبات 📋

- Dart SDK >= 3.0.0
- Flutter >= 3.10.0

## المطور 👨‍💻

Mohamed Abo Elnasr Hassan
- GitHub: [MohamedAboElnasrHassan](https://github.com/MohamedAboElnasrHassan)
