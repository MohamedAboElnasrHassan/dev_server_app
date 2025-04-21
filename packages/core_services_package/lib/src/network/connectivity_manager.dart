import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../base/base_service.dart';
import '../logging/logger.dart';

/// مدير الاتصال
class ConnectivityManager extends BaseService {
  final Connectivity _connectivity = Connectivity();
  late final Logger _logger;
  late StreamSubscription<ConnectivityResult> _subscription;

  final isConnected = true.obs;
  final connectionType = ConnectivityResult.none.obs;

  Future<ConnectivityManager> init() async {
    await initService();

    // الحصول على مدير السجلات
    _logger = Get.find<Logger>();

    // التحقق من حالة الاتصال الحالية
    await _checkConnectivity();

    // الاستماع للتغييرات في حالة الاتصال
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
    );

    return this;
  }

  /// التحقق من حالة الاتصال الحالية
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivity(result);
    } catch (e) {
      _logger.error('Error checking connectivity: $e');
      isConnected.value = false;
      connectionType.value = ConnectivityResult.none;
    }
  }

  /// تحديث حالة الاتصال
  void _updateConnectivity(ConnectivityResult result) {
    connectionType.value = result;
    isConnected.value = result != ConnectivityResult.none;

    _logger.info(
      'Connectivity changed: $result, Connected: ${isConnected.value}',
    );
  }

  /// الحصول على نوع الاتصال الحالي
  ConnectivityResult get currentConnectionType => connectionType.value;

  /// التحقق من وجود اتصال بالإنترنت
  bool get hasConnection => isConnected.value;

  /// التحقق من وجود اتصال WiFi
  bool get isWifi => connectionType.value == ConnectivityResult.wifi;

  /// التحقق من وجود اتصال بيانات الجوال
  bool get isMobile => connectionType.value == ConnectivityResult.mobile;

  /// التحقق من وجود اتصال إيثرنت
  bool get isEthernet => connectionType.value == ConnectivityResult.ethernet;

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
