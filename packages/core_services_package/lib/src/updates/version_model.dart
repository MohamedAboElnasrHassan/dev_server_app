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
  final Map<String, String> assets;
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
    this.repository = const {'owner': 'Mohamed', 'name': 'dev_server', 'branch': 'main'},
    required this.assets,
    this.notesUrl,
    this.changeLog,
    this.releaseDate,
    this.updateSettings,
  });

  /// إنشاء من JSON
  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    // تحويل repository
    final Map<String, dynamic> repository;
    if (json['repository'] != null && json['repository'] is Map) {
      repository = Map<String, dynamic>.from(json['repository'] as Map);
    } else {
      repository = {'owner': 'Mohamed', 'name': 'dev_server', 'branch': 'main'};
    }

    // تحويل assets
    final Map<String, String> assetsMap;
    if (json['assets'] != null && json['assets'] is Map) {
      assetsMap = Map<String, String>.from(json['assets'] as Map);
    } else {
      assetsMap = {};
    }

    // تحويل update_settings
    final Map<String, dynamic>? updateSettings;
    if (json['update_settings'] != null && json['update_settings'] is Map) {
      updateSettings = Map<String, dynamic>.from(json['update_settings'] as Map);
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
      assets: assetsMap,
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
      'assets': assets,
      'notes_url': notesUrl,
      'change_log': changeLog,
      'release_date': releaseDate,
      'update_settings': updateSettings,
    };
  }

  /// التحقق مما إذا كان هذا الإصدار أحدث من الإصدار الحالي
  bool isNewerThan(String currentVersion) {
    try {
      final current = Version.parse(currentVersion);
      final latest = Version.parse(version);
      return latest > current;
    } catch (e) {
      return false;
    }
  }

  /// التحقق مما إذا كان الإصدار الحالي يلبي الحد الأدنى المطلوب
  bool meetsMinimumRequirement(String currentVersion) {
    if (minVersion == null) return true;

    try {
      final current = Version.parse(currentVersion);
      final minimum = Version.parse(minVersion!);
      return current >= minimum;
    } catch (e) {
      return true;
    }
  }

  /// الحصول على رابط التنزيل للمنصة المحددة
  String? getDownloadUrl(String platform) {
    return assets[platform];
  }
}
