import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../base/app_base.dart';
import '../logging/logger.dart';
import '../storage/storage_manager.dart';
import 'version_model.dart';

/// مدير التحديثات
class UpdateManager extends BaseService {
  final Logger _logger = Get.find<Logger>();
  final StorageManager _storageManager = Get.find<StorageManager>();
  final Dio _dio = Dio();

  String get _updateConfigUrl {
    // Get configuration file URL from GitHub
    // This is updated with your actual repository URL
    return 'https://raw.githubusercontent.com/MohamedAboElnasrHassan/dev_server/main/app-config.json';
  }

  // Flag to enable/disable update checks (useful for development)
  final bool _enableUpdateChecks = true;
  final String _lastCheckKey = 'last_update_check';
  final String _skipVersionKey = 'skip_update_version';

  final isCheckingForUpdates = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final currentVersion = ''.obs;
  final latestVersion = Rx<VersionInfo?>(null);
  final updateAvailable = false.obs;
  final updateRequired = false.obs;

  Future<UpdateManager> init() async {
    await initService();

    // الحصول على معلومات الإصدار الحالي
    final packageInfo = await PackageInfo.fromPlatform();
    currentVersion.value = packageInfo.version;

    _logger.info('Update manager initialized. Current version: ${currentVersion.value}');

    return this;
  }

  /// Check for updates
  Future<bool> checkForUpdates({bool force = false}) async {
    // Skip update checks if disabled
    if (!_enableUpdateChecks) {
      _logger.info('Update checks are disabled');
      return false;
    }

    if (isCheckingForUpdates.value) return false;

    try {
      isCheckingForUpdates.value = true;

      // التحقق من تاريخ آخر فحص (إذا لم يكن مطلوبًا)
      if (!force) {
        final lastCheck = await _storageManager.read<String>(_lastCheckKey);
        if (lastCheck != null) {
          final lastCheckDate = DateTime.parse(lastCheck);
          final now = DateTime.now();
          // إذا تم الفحص خلال الـ 24 ساعة الماضية، تخطي
          if (now.difference(lastCheckDate).inHours < 24) {
            isCheckingForUpdates.value = false;
            return updateAvailable.value;
          }
        }
      }

      // تحديث تاريخ آخر فحص
      await _storageManager.write(_lastCheckKey, DateTime.now().toIso8601String());

      // الحصول على معلومات أحدث إصدار
      final response = await _dio.get(_updateConfigUrl);
      if (response.statusCode == 200) {
        // استبدال متغيرات {version} في الروابط
        String configData;
        if (response.data is String) {
          configData = response.data as String;
        } else {
          configData = jsonEncode(response.data);
        }

        // استبدال متغيرات {version} برقم الإصدار الحالي
        final data = jsonDecode(configData);

        // استخراج بيانات التحديث من ملف app-config.json
        final appData = data['app'] as Map<String, dynamic>;
        final updateData = data['update'] as Map<String, dynamic>;

        // إنشاء كائن التحديث
        final Map<String, dynamic> updateInfo = {
          'app_name': appData['name'],
          'app_id': appData['id'],
          'version': appData['version'],
          'build_number': appData['build_number'],
          'required': updateData['required'],
          'min_version': updateData['min_version'],
          'notes_url': updateData['notes_url'],
          'change_log': updateData['change_log'],
          'release_date': updateData['release_date'],
          'assets': updateData['assets']
        };

        // استبدال المتغيرات في الروابط
        final String appName = appData['name'] ?? 'Dev Server';
        final String appNameFormatted = appName.replaceAll(' ', '_').toLowerCase();
        final String version = appData['version'];

        if (updateInfo['notes_url'] is String) {
          updateInfo['notes_url'] = updateInfo['notes_url'].toString()
              .replaceAll('{version}', version)
              .replaceAll('{app_name}', appNameFormatted);
        }

        if (updateInfo['assets'] is Map) {
          final assets = updateInfo['assets'] as Map<String, dynamic>;
          assets.forEach((platform, url) {
            if (url is String) {
              assets[platform] = url
                  .replaceAll('{version}', version)
                  .replaceAll('{app_name}', appNameFormatted);
            }
          });
        }

        final versionInfo = VersionInfo.fromJson(updateInfo);
        latestVersion.value = versionInfo;

        // التحقق مما إذا كان الإصدار الحالي يلبي الحد الأدنى المطلوب
        final meetsMinRequirement = versionInfo.meetsMinimumRequirement(currentVersion.value);

        // التحقق مما إذا كان هناك إصدار أحدث
        final isNewer = versionInfo.isNewerThan(currentVersion.value);

        // التحقق مما إذا كان المستخدم قد تخطى هذا الإصدار
        final skippedVersion = await _storageManager.read<String>(_skipVersionKey);
        final isSkipped = skippedVersion == versionInfo.version;

        updateAvailable.value = isNewer && !isSkipped;
        updateRequired.value = versionInfo.required && !meetsMinRequirement;

        _logger.info('Update check completed. Current version: ${currentVersion.value}, Latest version: ${versionInfo.version}, Available: ${updateAvailable.value}, Required: ${updateRequired.value}');

        isCheckingForUpdates.value = false;
        return updateAvailable.value;
      }
    } catch (e) {
      _logger.error('Error checking for updates', error: e);
    }

    isCheckingForUpdates.value = false;
    return false;
  }

  /// تنزيل التحديث
  Future<String?> downloadUpdate() async {
    if (isDownloading.value || latestVersion.value == null) return null;

    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;

      // الحصول على رابط التنزيل للمنصة الحالية
      final platform = _getPlatformName();
      final downloadUrl = latestVersion.value!.getDownloadUrl(platform);

      if (downloadUrl == null) {
        _logger.error('No download URL for platform: $platform');
        isDownloading.value = false;
        return null;
      }

      // الحصول على مسار التنزيل
      final directory = await getTemporaryDirectory();
      final fileName = downloadUrl.split('/').last;
      final savePath = '${directory.path}/$fileName';

      // تنزيل الملف
      await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      isDownloading.value = false;
      downloadProgress.value = 1.0;

      _logger.info('Update downloaded successfully: $savePath');

      return savePath;
    } catch (e) {
      _logger.error('Error downloading update', error: e);
      isDownloading.value = false;
      return null;
    }
  }

  /// تثبيت التحديث
  Future<bool> installUpdate(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);

      _logger.info('Update file opened: $filePath, Result: ${result.message}');

      return result.type == ResultType.done;
    } catch (e) {
      _logger.error('Error installing update', error: e);
      return false;
    }
  }

  /// تخطي هذا الإصدار
  Future<void> skipVersion() async {
    if (latestVersion.value != null) {
      await _storageManager.write(_skipVersionKey, latestVersion.value!.version);
      updateAvailable.value = false;
    }
  }

  /// فتح صفحة الإصدار
  Future<bool> openReleaseNotes() async {
    if (latestVersion.value?.notesUrl != null) {
      final url = Uri.parse(latestVersion.value!.notesUrl!);
      return await launchUrl(url);
    }
    return false;
  }

  /// الحصول على اسم المنصة الحالية
  String _getPlatformName() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
