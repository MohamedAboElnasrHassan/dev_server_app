# Auto Update Package 🔄

حزمة التحديث التلقائي لتطبيق Dev Server. توفر هذه الحزمة وظائف التحقق من وجود تحديثات جديدة، وتنزيلها، وتثبيتها بشكل تلقائي.

## المميزات 💪

- 🔍 التحقق من وجود تحديثات جديدة بشكل تلقائي
- 💾 تنزيل التحديثات مع عرض تقدم التنزيل
- 📍 تثبيت التحديثات بنقرة واحدة
- 💻 دعم جميع المنصات (Windows, macOS, Linux, Android, iOS)
- 👌 واجهة مستخدم سهلة الاستخدام
- 🔒 إمكانية تخطي التحديثات غير المطلوبة
- 📄 عرض ملاحظات الإصدار وسجل التغييرات

## الاستخدام 💻

```dart
import 'package:auto_update_package/auto_update_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

// مثال كامل لاستخدام حزمة التحديث التلقائي
class UpdateService {
  late UpdateManager updateManager;
  final SharedPreferences prefs;

  UpdateService(this.prefs) {
    // إنشاء مدير التحديثات
    updateManager = UpdateManager(
      configUrl: 'https://raw.githubusercontent.com/MohamedAboElnasrHassan/dev_server/main/app-config.json',
      readStorage: (key) async => prefs.getString(key),
      writeStorage: (key, value) async => prefs.setString(key, value.toString()),
      logInfo: (message) => print('📡 INFO: $message'),
      logError: (message, {error}) => print('❌ ERROR: $message - $error'),
    );
  }

  // تهيئة الخدمة
  Future<void> init() async {
    await updateManager.init();
    print('🔄 Update service initialized');
  }

  // التحقق من وجود تحديثات
  Future<bool> checkForUpdates({bool force = false}) async {
    print('🔍 Checking for updates...');
    return await updateManager.checkForUpdates(force: force);
  }

  // عرض حوار التحديث
  void showUpdateDialog(BuildContext context) {
    if (updateManager.updateAvailable.value && updateManager.latestVersion.value != null) {
      showDialog(
        context: context,
        barrierDismissible: !updateManager.updateRequired.value,
        builder: (context) => UpdateDialog(
          updateManager: updateManager,
          updateInfo: updateManager.latestVersion.value!,
          onSkip: () {
            print('🚪 Update skipped');
          },
          onInstallComplete: () {
            print('✅ Update installed');
          },
        ),
      );
    }
  }
}
```

## التكوين 📝

يجب أن يحتوي ملف التكوين `app-config.json` على الحقول التالية:

```json
{
  "app": {
    "name": "Dev Server",
    "id": "com.example.dev_server",
    "version": "1.0.0",
    "build_number": 1,
    "author": "Mohamed Abo Elnasr Hassan",
    "website": "https://github.com/MohamedAboElnasrHassan/dev_server"
  },
  "update": {
    "latest_version": "1.0.0",
    "latest_build_number": 1,
    "is_required": false,
    "min_version": "0.9.0",
    "repository": "https://github.com/MohamedAboElnasrHassan/dev_server",
    "check_interval_minutes": 60,
    "change_log": "الإصدار الأول من تطبيق Dev Server",
    "release_date": "2023-04-19",
    "notes_url": "https://github.com/MohamedAboElnasrHassan/dev_server/releases/tag/v{version}",
    "platforms": {
      "windows": {
        "enabled": true,
        "download_url": "https://github.com/MohamedAboElnasrHassan/dev_server/releases/download/v{app.version}/dev_server-v{app.version}-setup.exe",
        "file_name": "dev_server-v{app.version}-setup.exe"
      },
      "macos": {
        "enabled": true,
        "download_url": "https://github.com/MohamedAboElnasrHassan/dev_server/releases/download/v{app.version}/dev_server-v{app.version}.dmg",
        "file_name": "dev_server-v{app.version}.dmg"
      },
      "linux": {
        "enabled": true,
        "download_url": "https://github.com/MohamedAboElnasrHassan/dev_server/releases/download/v{app.version}/dev_server-v{app.version}.AppImage",
        "file_name": "dev_server-v{app.version}.AppImage"
      },
      "android": {
        "enabled": true,
        "download_url": "https://github.com/MohamedAboElnasrHassan/dev_server/releases/download/v{app.version}/dev_server-v{app.version}.apk",
        "file_name": "dev_server-v{app.version}.apk"
      },
      "ios": {
        "enabled": false,
        "download_url": "",
        "file_name": ""
      }
    }
  }
}
```

## المطور 👨‍💻

- **المطور**: Mohamed Abo Elnasr Hassan
- **GitHub**: [MohamedAboElnasrHassan](https://github.com/MohamedAboElnasrHassan)
