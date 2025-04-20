import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:open_filex/open_filex.dart';

/// خدمة التحديث التلقائي
class UpdateService {
  final Dio _dio = Dio();
  final String _configUrl;
  
  UpdateService({required String configUrl}) : _configUrl = configUrl;
  
  /// التحقق من وجود تحديث جديد
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      // الحصول على معلومات الحزمة الحالية
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version.split('+')[0]);
      
      // الحصول على معلومات التحديث من الخادم
      final response = await _dio.get(_configUrl);
      final config = json.decode(response.data);
      final updateConfig = config['update'];
      
      // التحقق من وجود تحديث جديد
      final latestVersion = Version.parse(updateConfig['latest_version']);
      
      if (latestVersion > currentVersion) {
        // تحديد منصة التشغيل
        String platform;
        if (Platform.isWindows) {
          platform = 'windows';
        } else if (Platform.isMacOS) {
          platform = 'macos';
        } else if (Platform.isLinux) {
          platform = 'linux';
        } else if (Platform.isAndroid) {
          platform = 'android';
        } else if (Platform.isIOS) {
          platform = 'ios';
        } else {
          return null;
        }
        
        // التحقق من دعم المنصة
        final platformConfig = updateConfig['platforms'][platform];
        if (platformConfig == null || platformConfig['enabled'] != true) {
          return null;
        }
        
        // إنشاء معلومات التحديث
        return UpdateInfo(
          currentVersion: currentVersion.toString(),
          latestVersion: latestVersion.toString(),
          downloadUrl: _replaceVariables(platformConfig['download_url'], config),
          fileName: _replaceVariables(platformConfig['file_name'], config),
          isRequired: updateConfig['is_required'] ?? false,
          releaseNotes: updateConfig['change_log'] ?? 'New version available',
          platform: platform,
        );
      }
      
      return null; // لا يوجد تحديث جديد
    } catch (e) {
      print('Error checking for update: $e');
      return null;
    }
  }
  
  /// تنزيل التحديث
  Future<String?> downloadUpdate(UpdateInfo updateInfo) async {
    try {
      // الحصول على مجلد التنزيلات
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${updateInfo.fileName}';
      
      // تنزيل الملف
      await _dio.download(
        updateInfo.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );
      
      return filePath;
    } catch (e) {
      print('Error downloading update: $e');
      return null;
    }
  }
  
  /// تثبيت التحديث
  Future<bool> installUpdate(String filePath) async {
    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // فتح ملف التثبيت
        final result = await OpenFilex.open(filePath);
        return result.type == ResultType.done;
      } else if (Platform.isAndroid) {
        // تثبيت APK
        final result = await OpenFilex.open(filePath);
        return result.type == ResultType.done;
      } else if (Platform.isIOS) {
        // فتح رابط App Store
        final packageInfo = await PackageInfo.fromPlatform();
        final url = 'itms-apps://itunes.apple.com/app/id${packageInfo.packageName}';
        return await launchUrl(Uri.parse(url));
      }
      
      return false;
    } catch (e) {
      print('Error installing update: $e');
      return false;
    }
  }
  
  /// استبدال المتغيرات في النص
  String _replaceVariables(String text, Map<String, dynamic> config) {
    final appConfig = config['app'];
    
    return text
        .replaceAll('{app.version}', appConfig['version'])
        .replaceAll('{app.name}', appConfig['name']);
  }
}

/// معلومات التحديث
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String fileName;
  final bool isRequired;
  final String releaseNotes;
  final String platform;
  
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.fileName,
    required this.isRequired,
    required this.releaseNotes,
    required this.platform,
  });
}
