import 'package:get/get.dart';
import '../../../../core/updates/update_manager.dart';

class UpdateController extends GetxController {
  final UpdateManager _updateManager = Get.find<UpdateManager>();

  // ربط المتغيرات التفاعلية من مدير التحديثات
  RxBool get isCheckingForUpdates => _updateManager.isCheckingForUpdates;
  RxBool get isDownloading => _updateManager.isDownloading;
  RxDouble get downloadProgress => _updateManager.downloadProgress;
  RxString get currentVersion => _updateManager.currentVersion;
  RxBool get updateAvailable => _updateManager.updateAvailable;
  RxBool get updateRequired => _updateManager.updateRequired;

  // إتاحة مدير التحديثات للوصول من الخارج
  UpdateManager get updateManager => _updateManager;

  @override
  void onInit() {
    super.onInit();
    checkForUpdates();
  }

  /// التحقق من وجود تحديثات
  Future<bool> checkForUpdates({bool force = false}) async {
    return await _updateManager.checkForUpdates(force: force);
  }

  /// تنزيل وتثبيت التحديث
  Future<void> downloadAndInstallUpdate() async {
    final filePath = await _updateManager.downloadUpdate();
    if (filePath != null) {
      await _updateManager.installUpdate(filePath);
    }
  }

  /// تخطي هذا الإصدار
  Future<void> skipVersion() async {
    await _updateManager.skipVersion();
    Get.back();
  }

  /// فتح صفحة ملاحظات الإصدار
  Future<void> openReleaseNotes() async {
    await _updateManager.openReleaseNotes();
  }
}
