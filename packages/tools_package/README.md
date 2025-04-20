# Tools Package 🛠️

حزمة أدوات التطوير والتكامل مع GitHub لتطبيق Dev Server. توفر هذه الحزمة مجموعة من الأدوات لتسهيل عملية التطوير والنشر والتكامل مع GitHub.

## المميزات 💪

- 🔗 إنشاء وإدارة مستودع GitHub
- 🔄 مزامنة التكوين بين المشروع والمستودع
- 🏗️ بناء التطبيق لجميع المنصات المدعومة (Windows, macOS, Linux, Android)
- 🏷️ إنشاء إصدارات جديدة وإدارة أرقام الإصدارات
- 📦 نشر الإصدارات على GitHub مع رفع ملفات التثبيت
- 📊 تتبع تغييرات الإصدارات وسجل التغييرات
- 🔧 أدوات مساعدة لتطوير وصيانة المشروع

## الاستخدام 💻

### استخدام الحزمة في التطبيق

```dart
import 'package:tools_package/tools_package.dart';

// إنشاء مستودع GitHub
await GitHubTools.createRepository();

// مزامنة التكوين
await GitHubTools.syncConfig();

// بناء التطبيق (windows, macos, linux, android, أو all)
await GitHubTools.buildApp('windows');

// إنشاء إصدار جديد (الإصدار، رقم البناء، هل التحديث إلزامي)
await GitHubTools.createRelease('1.0.0', '1', false);

// نشر الإصدار على GitHub
await GitHubTools.publishRelease('1.0.0', '1');

// أو تنفيذ جميع الخطوات تلقائياً
await GitHubTools.autoRelease('1.0.0', '1', false);
```

### استخدام الأوامر من سطر الأوامر

```bash
# إنشاء مستودع GitHub
dart melos_runner.dart run github:create-repo

# مزامنة التكوين
dart melos_runner.dart run github:sync-config

# بناء التطبيق
dart melos_runner.dart run github:build-app windows

# إنشاء إصدار جديد
dart melos_runner.dart run github:create-release 1.0.0 1 false

# نشر الإصدار على GitHub
dart melos_runner.dart run github:publish-release 1.0.0 1

# تنفيذ جميع الخطوات تلقائياً
dart melos_runner.dart run github:auto-release 1.0.0 1 false
```

## التكوين 📝

يجب أن يحتوي ملف `config/app-config.json` على الحقول التالية:

```json
{
  "app": {
    "name": "Dev Server",
    "id": "com.example.dev_server",
    "version": "1.0.0",
    "build_number": 1,
    "author": "Your Name",
    "website": "https://example.com"
  },
  "repository": {
    "owner": "username",
    "name": "repo",
    "branch": "main",
    "base_url": "https://github.com/{repository.owner}/{repository.name}",
    "releases_url": "{repository.base_url}/releases",
    "download_url": "{repository.base_url}/releases/download/v{app.version}"
  },
  "github": {
    "token": "YOUR_GITHUB_TOKEN",
    "auto_create": true,
    "auto_push": true,
    "auto_release": true,
    "auto_tag": true,
    "auto_build": true,
    "auto_analyze": true,
    "auto_sync": true
  },
  "update": {
    "latest_version": "1.0.0",
    "latest_build_number": 1,
    "is_required": false,
    "repository": "https://github.com/username/repo",
    "check_interval_minutes": 60,
    "change_log": "وصف التغييرات في هذا الإصدار",
    "release_date": "2023-04-19",
    "platforms": {
      "windows": {
        "enabled": true,
        "download_url": "https://github.com/username/repo/releases/download/v{app.version}/app-v{app.version}-setup.exe",
        "file_name": "app-v{app.version}-setup.exe"
      },
      "macos": {
        "enabled": true,
        "download_url": "https://github.com/username/repo/releases/download/v{app.version}/app-v{app.version}.dmg",
        "file_name": "app-v{app.version}.dmg"
      }
    }
  }
}
```

## الوظائف المتاحة 📋

### إدارة المستودع

- `createRepository()`: إنشاء مستودع GitHub جديد
- `syncConfig()`: مزامنة التكوين بين المشروع والمستودع

### إدارة الإصدارات

- `getVersion()`: الحصول على الإصدار الحالي
- `bumpVersion()`: زيادة رقم الإصدار تلقائياً
- `createRelease(version, buildNumber, isRequired)`: إنشاء إصدار جديد
- `publishRelease(version, buildNumber, isRequired)`: نشر الإصدار على GitHub

### بناء التطبيق

- `buildApp(platform)`: بناء التطبيق للمنصة المحددة

## المتطلبات 📋

- Dart SDK >= 3.0.0
- Flutter >= 3.10.0
- توكن GitHub مع صلاحيات الوصول للمستودع

## المطور 👨‍💻

Mohamed Abo Elnasr Hassan
- GitHub: [MohamedAboElnasrHassan](https://github.com/MohamedAboElnasrHassan)
