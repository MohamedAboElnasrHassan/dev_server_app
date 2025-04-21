import 'package:version/version.dart';

/// نموذج معلومات الإصدار
class VersionInfo {
  final String appName;
  final String appId;
  final String version;
  final int buildNumber;
  final bool required;
  final String? minVersion;
  final Map<String, dynamic> repository;
  final Map<String, dynamic> platforms;
  final String? notesUrl;
  final String? changeLog;
  final String? releaseDate;
  final Map<String, dynamic>? updateSettings;

  VersionInfo({
    this.appName = 'Dev Server',
    this.appId = 'com.mohamed.dev_server',
    required this.version,
    this.buildNumber = 1,
    this.required = false,
    this.minVersion,
    this.repository = const {
      'owner': 'Mohamed',
      'name': 'dev_server',
      'branch': 'main',
    },
    this.platforms = const {},
    this.notesUrl,
    this.changeLog,
    this.releaseDate,
    this.updateSettings,
  });

  /// إنشاء من JSON
  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    final platformsMap = <String, dynamic>{};
    if (json['platforms'] != null && json['platforms'] is Map) {
      platformsMap.addAll(Map<String, dynamic>.from(json['platforms'] as Map));
    } else if (json['assets'] != null && json['assets'] is Map) {
      // للتوافق مع الهيكل القديم
      final assets = json['assets'] as Map<String, dynamic>;
      assets.forEach((key, value) {
        if (value is String) {
          platformsMap[key] = {
            'enabled': true,
            'download_url': value,
            'file_name': value.split('/').last,
          };
        }
      });
    }

    final Map<String, dynamic> repository;
    if (json['repository'] != null && json['repository'] is Map) {
      repository = Map<String, dynamic>.from(json['repository'] as Map);
    } else {
      repository = {'owner': 'Mohamed', 'name': 'dev_server', 'branch': 'main'};
    }

    final Map<String, dynamic>? updateSettings;
    if (json['update_settings'] != null && json['update_settings'] is Map) {
      updateSettings = Map<String, dynamic>.from(
        json['update_settings'] as Map,
      );
    } else {
      updateSettings = null;
    }

    return VersionInfo(
      appName: json['app_name'] ?? 'Dev Server',
      appId: json['app_id'] ?? 'com.mohamed.dev_server',
      version: json['version'] ?? '0.0.0',
      buildNumber: json['build_number'] ?? 1,
      required: json['required'] ?? false,
      minVersion: json['min_version'],
      repository: repository,
      platforms: platformsMap,
      notesUrl: json['notes_url'],
      changeLog: json['change_log'],
      releaseDate: json['release_date'],
      updateSettings: updateSettings,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'app_id': appId,
      'version': version,
      'build_number': buildNumber,
      'required': required,
      'min_version': minVersion,
      'repository': repository,
      'platforms': platforms,
      'notes_url': notesUrl,
      'change_log': changeLog,
      'release_date': releaseDate,
      'update_settings': updateSettings,
    };
  }

  /// التحقق مما إذا كان هذا الإصدار أحدث من الإصدار الحالي
  bool isNewerThan(dynamic currentVersion) {
    if (currentVersion is VersionInfo) {
      try {
        final current = Version.parse(currentVersion.version);
        final latest = Version.parse(version);

        // إذا كان رقم الإصدار متساويًا، تحقق من رقم البناء
        if (latest == current) {
          return buildNumber > currentVersion.buildNumber;
        }

        return latest > current;
      } catch (e) {
        return false;
      }
    } else if (currentVersion is String) {
      try {
        final current = Version.parse(currentVersion);
        final latest = Version.parse(version);
        return latest > current;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// التحقق مما إذا كان الإصدار الحالي يلبي الحد الأدنى المطلوب
  bool meetsMinimumRequirement(dynamic currentVersion) {
    if (minVersion == null) return true;

    if (currentVersion is VersionInfo) {
      try {
        final current = Version.parse(currentVersion.version);
        final minimum = Version.parse(minVersion!);
        return current >= minimum;
      } catch (e) {
        return true;
      }
    } else if (currentVersion is String) {
      try {
        final current = Version.parse(currentVersion);
        final minimum = Version.parse(minVersion!);
        return current >= minimum;
      } catch (e) {
        return true;
      }
    }
    return true;
  }

  /// الحصول على رابط التنزيل للمنصة الحالية
  String? getDownloadUrl(String platform) {
    final platformKey = platform.toLowerCase();
    if (platforms.containsKey(platformKey)) {
      final platformData = platforms[platformKey];
      if (platformData is Map && platformData['enabled'] == true) {
        return platformData['download_url'] as String?;
      }
    }
    return null;
  }

  /// الحصول على اسم ملف التنزيل للمنصة الحالية
  String? getFileName(String platform) {
    final platformKey = platform.toLowerCase();
    if (platforms.containsKey(platformKey)) {
      final platformData = platforms[platformKey];
      if (platformData is Map && platformData['enabled'] == true) {
        return platformData['file_name'] as String?;
      }
    }
    return null;
  }
}
