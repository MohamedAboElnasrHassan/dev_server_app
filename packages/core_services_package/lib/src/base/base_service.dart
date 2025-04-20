import 'package:get/get.dart';

/// قاعدة لجميع الخدمات في التطبيق
abstract class BaseService extends GetxService {
  // دالة التهيئة العامة للخدمات
  Future<void> initService() async {
    printInfo(info: '${runtimeType.toString()} initialized');
  }

  @override
  void onClose() {
    printInfo(info: '${runtimeType.toString()} closed');
    super.onClose();
  }
}
