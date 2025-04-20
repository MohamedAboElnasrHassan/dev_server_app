import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../base/base_service.dart';
import '../logging/logger.dart';
import '../storage/storage_manager.dart';
import 'version_model.dart';

/// مدير التحديثات
class UpdateManager extends BaseService {
  late final Logger _logger;
  late final StorageManager _storageManager;
  final Dio _dio = Dio();

  // مفاتيح التخزين
  final _lastCheckKey = 'last_update_check';
  final _skipVersionKey = 'skip_version';
  final _enableUpdateChecksKey = 'enable_update_checks';

  // حالة التحديث
  final currentVersion = '1.0.0'.obs;
  final latestVersion = Rx<VersionInfo?>(null);
  final updateAvailable = false.obs;
  final updateRequired = false.obs;
  final isCheckingForUpdates = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;

  // إعدادات
  bool _enableUpdateChecks = true;

  String get _updateConfigUrl {
    // Get configuration file URL from GitHub
    // This is updated with your actual repository URL
    return 'https://raw.githubusercontent.com/MohamedAboElnasrHassan/dev_server/main/app-config.json';
  }

  Future<UpdateManager> init() async {
    await initService();
    
    // الحصول على مدير السجلات والتخزين
    _logger = Get.find<Logger>();
    _storageManager = Get.find<StorageManager>();

    // تحميل الإعدادات
    await _loadSettings();

    return this;
  }

  /// تحميل إعدادات التحديث
  Future<void> _loadSettings() async {
    // تحميل إعدادات التحديث
    final enableChecks = await _storageManager.read<bool>(_enableUpdateChecksKey);
    if (enableChecks != null) {
      _enableUpdateChecks = enableChecks;
    }
  }

  /// تعيين الإصدار الحالي
  void setCurrentVersion(String version) {
    currentVersion.value = version;
  }

  /// تمكين أو تعطيل فحص التحديثات
  Future<void> setEnableUpdateChecks(bool enable) async {
    _enableUpdateChecks = enable;
    await _storageManager.write(_enableUpdateChecksKey, enable);
  }

  /// التحقق من وجود تحديثات
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

      // الحصول على معلومات التحديث
      final response = await _dio.get(_updateConfigUrl);
      if (response.statusCode == 200) {
        final updateInfo = response.data;
        if (updateInfo == null) {
          _logger.error('Invalid update info format');
          isCheckingForUpdates.value = false;
          return false;
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

        _logger.info('Update check completed. Available: ${updateAvailable.value}, Required: ${updateRequired.value}');

        isCheckingForUpdates.value = false;
        return updateAvailable.value;
      } else {
        _logger.error('Failed to check for updates: ${response.statusCode}');
        isCheckingForUpdates.value = false;
        return false;
      }
    } catch (e) {
      _logger.error('Error checking for updates', error: e);
      isCheckingForUpdates.value = false;
      return false;
    }
  }

  /// تخطي الإصدار الحالي
  Future<void> skipCurrentVersion() async {
    if (latestVersion.value != null) {
      await _storageManager.write(_skipVersionKey, latestVersion.value!.version);
      updateAvailable.value = false;
    }
  }

  /// الحصول على اسم المنصة الحالية
  String _getPlatformName() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// تنزيل التحديث
  Future<String?> downloadUpdate() async {
    if (latestVersion.value == null) return null;

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
}
