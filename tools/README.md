# Dev Server App

تطبيق خادم التطوير مع دعم التحديث التلقائي وتكامل مع GitHub.

## المميزات

- ✅ تطبيق متعدد المنصات (Windows, macOS, Linux, Android, iOS)
- ✅ دعم التحديث التلقائي
- ✅ تكامل مع GitHub للنشر والتحديث
- ✅ واجهة مستخدم بسيطة وسهلة الاستخدام
- ✅ دعم اللغة العربية والإنجليزية
- ✅ أدوات تطوير متكاملة وسهلة الاستخدام

## متطلبات التطوير

- Flutter SDK
- Dart SDK
- للتطوير على Windows: Visual Studio مع C++ build tools
- للتطوير على macOS: Xcode
- للتطوير على Linux: حزم التطوير المطلوبة

## البناء والنشر

### أدوات التطوير

يحتوي المشروع على مجموعة من الأدوات المساعدة في مجلد `tools`:

```bash
# تشغيل الأداة بدون معاملات لعرض القائمة التفاعلية
dart tools/dev_tools.dart

# مزامنة التكوين
dart tools/dev_tools.dart sync

# إنشاء إصدار جديد
# الصيغة: dart tools/dev_tools.dart release <version> <build_number> [is_required]
dart tools/dev_tools.dart release 1.0.2 3 false

# بناء التطبيق
# الصيغة: dart tools/dev_tools.dart build <platform>
dart tools/dev_tools.dart build windows
dart tools/dev_tools.dart build macos
dart tools/dev_tools.dart build linux
dart tools/dev_tools.dart build all

# نشر إصدار جديد
# الصيغة: dart tools/dev_tools.dart publish <version> <build_number> [is_required]
dart tools/dev_tools.dart publish 1.0.2 3 false

# إعداد توكن GitHub
dart tools/dev_tools.dart set-token YOUR_TOKEN

# تنفيذ جميع الخطوات تلقائياً (إنشاء، بناء، نشر)
dart tools/dev_tools.dart auto 1.0.2 3 false
```

## ملف التثبيت

يتم إنشاء ملف تثبيت احترافي باستخدام Inno Setup مع المميزات التالية:

- واجهة مستخدم مخصصة
- دعم اللغة العربية والإنجليزية
- تضمين ملفات Microsoft Visual C++ Runtime المطلوبة
- خيارات تثبيت متقدمة
- إلغاء تثبيت كامل

### إنشاء ملف التثبيت باستخدام GitHub Actions

```bash
# إنشاء علامة جديدة لإطلاق إصدار جديد
git tag v1.0.1
git push origin v1.0.1
```

## النشر التلقائي باستخدام GitHub Actions

يتم نشر التطبيق تلقائيًا باستخدام GitHub Actions عند إنشاء علامة (tag) جديدة تبدأ بـ `v`:

```bash
# إنشاء علامة جديدة
git tag v1.0.1
git push origin v1.0.1
```

سيقوم GitHub Actions تلقائيًا بما يلي:

1. بناء التطبيق لنظام Windows
2. إنشاء ملف تثبيت باستخدام Inno Setup
3. بناء التطبيق لنظام macOS وإنشاء ملف DMG
4. بناء التطبيق لنظام Linux وإنشاء ملف AppImage
5. نشر كل الملفات في GitHub Releases

## التكوين

يمكن تكوين التطبيق من خلال ملف `tools/app-config.json` الذي يحتوي على الإعدادات التالية:

- معلومات التطبيق (الاسم، الإصدار، الوصف، إلخ)
- إعدادات التحديث التلقائي
- إعدادات البناء لكل منصة
- إعدادات ملف التثبيت
- إعدادات GitHub (التوكن، الإنشاء التلقائي، إلخ)

يمكن مزامنة التكوين باستخدام الأمر التالي:

```bash
dart tools/dev_tools.dart sync
```

سيقوم هذا الأمر بتحديث جميع ملفات المشروع المرتبطة بالتكوين مثل `pubspec.yaml`.

## الترخيص

هذا المشروع مرخص بموجب [رخصة MIT](LICENSE).

## المساهمة

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:

1. قم بعمل fork للمستودع
2. قم بإنشاء فرع جديد: `git checkout -b feature/my-feature`
3. قم بإجراء التغييرات وإضافتها: `git add .`
4. قم بعمل commit: `git commit -m "إضافة ميزة جديدة"`
5. قم بدفع التغييرات: `git push origin feature/my-feature`
6. قم بإنشاء طلب سحب (Pull Request)

## الاتصال

- **المطور**: Mohamed Abo Elnasr Hassan
- **GitHub**: [MohamedAboElnasrHassan](https://github.com/MohamedAboElnasrHassan)
