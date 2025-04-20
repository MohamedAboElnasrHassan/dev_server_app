# Dev Server

تطبيق خادم التطوير مع دعم التحديث التلقائي وتكامل مع GitHub. يوفر هذا التطبيق بيئة متكاملة للتطوير مع إمكانية التحديث التلقائي ونشر الإصدارات على GitHub بسهولة.

## المميزات 💪

- 💻 تطبيق متعدد المنصات (Windows, macOS, Linux, Android, iOS)
- 🔄 دعم التحديث التلقائي
- 🔗 تكامل مع GitHub للنشر والتحديث
- 👌 واجهة مستخدم بسيطة وسهلة الاستخدام
- 🌐 دعم اللغة العربية والإنجليزية
- 🛠️ أدوات تطوير متكاملة وسهلة الاستخدام

## هيكل المشروع 📚

هذا المشروع منظم كـ monorepo باستخدام [Melos](https://pub.dev/packages/melos):

```bash
dev_server/
├── apps/
│   └── dev_server_app/     # التطبيق الرئيسي
├── packages/
│   ├── tools_package/      # حزمة أدوات التطوير
│   └── auto_update_package/# حزمة التحديث التلقائي
├── lib/                   # مجلد الكود القديم (مرجع)
└── melos.yaml              # ملف تكوين Melos
```

## الاستخدام السريع 🚀

### الخطوة 1: إعداد توكن GitHub 🔑

قم بتعديل ملف `packages/tools_package/lib/config/app-config.json` وإضافة توكن GitHub في حقل `github.token`

### الخطوة 2: تثبيت التبعيات 💾

```bash
dart melos_runner.dart bootstrap
```

### الخطوة 3: تشغيل الأوامر المخصصة 🛠️

```bash
# إنشاء مستودع GitHub 🔗
dart melos_runner.dart run github:create-repo

# مزامنة التكوين 🔄
dart melos_runner.dart run github:sync-config

# الحصول على الإصدار الحالي 🔍
dart melos_runner.dart run version:get

# بناء التطبيق لنظام Windows 💻
dart melos_runner.dart run build:windows

# إنشاء حزمة تثبيت 💾
dart melos_runner.dart run create:installer

# نشر إصدار على GitHub 📤
dart melos_runner.dart run github:publish

# أو تنفيذ جميع الخطوات تلقائياً 🚀
dart melos_runner.dart run release:auto
```

## الأوامر المتاحة 📝

### أوامر التطوير

| الأمر | الوصف |
|------|------|
| `analyze` | تحليل الكود في جميع الحزم |
| `format` | تنسيق الكود في جميع الحزم |
| `lint:all` | تشغيل التحليل والتنسيق معاً |
| `clean:deep` | تنظيف عميق للمشروع |
| `test` | تشغيل الاختبارات في جميع الحزم |

### أوامر البناء

| الأمر | الوصف |
|------|------|
| `build:windows` | بناء تطبيق Windows |
| `build:macos` | بناء تطبيق macOS |
| `build:linux` | بناء تطبيق Linux |
| `build:android` | بناء تطبيق Android |
| `build:ios` | بناء تطبيق iOS |
| `build:all` | بناء التطبيق لجميع المنصات |
| `create:installer` | إنشاء حزمة تثبيت |

### أوامر GitHub والإصدار

| الأمر | الوصف |
|------|------|
| `github:create-repo` | إنشاء مستودع GitHub |
| `github:sync-config` | مزامنة التكوين مع GitHub |
| `github:publish` | نشر إصدار على GitHub |
| `version:get` | الحصول على الإصدار الحالي |
| `version:bump` | زيادة رقم الإصدار |
| `release:auto` | تنفيذ جميع الخطوات تلقائياً |

## التطوير والمساهمة 🛠️

إذا كنت ترغب في المساهمة في هذا المشروع، يرجى اتباع الخطوات التالية:

1. قم بعمل Fork للمشروع
2. قم بإنشاء فرع (branch) جديد للميزة التي تريد إضافتها
3. قم بتنفيذ التغييرات الخاصة بك
4. قم بإرسال Pull Request

## الترخيص 📜

هذا المشروع مرخص بموجب رخصة MIT.

## المطور 👨‍💻

- **المطور**: Mohamed Abo Elnasr Hassan
- **GitHub**: [MohamedAboElnasrHassan](https://github.com/MohamedAboElnasrHassan)


