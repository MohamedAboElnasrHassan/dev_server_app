import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// قاعدة لجميع المتحكمات في التطبيق
abstract class BaseController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void startLoading() => isLoading.value = true;
  void stopLoading() => isLoading.value = false;

  void setError(String message) {
    errorMessage.value = message;
    stopLoading();
  }

  void clearError() => errorMessage.value = '';

  Future<T?> runAsync<T>(Future<T> Function() asyncFunction, {
    bool showLoading = true,
    bool showError = true,
  }) async {
    try {
      if (showLoading) startLoading();
      clearError();

      final result = await asyncFunction();

      if (showLoading) stopLoading();
      return result;
    } catch (e) {
      if (showLoading) stopLoading();

      final errorMsg = e.toString();
      setError(errorMsg);

      if (showError) {
        Get.snackbar(
          'خطأ',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(204), // 0.8 opacity (204/255)
          colorText: Colors.white,
        );
      }

      return null;
    }
  }
}

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

/// قاعدة لجميع المستودعات في التطبيق
abstract class BaseRepository {
  void logAction(String action) {
    printInfo(info: '${runtimeType.toString()}: $action');
  }
}

/// قاعدة لجميع مزودي البيانات في التطبيق
abstract class BaseProvider extends GetConnect {
  @override
  void onInit() {
    super.onInit();
    printInfo(info: '${runtimeType.toString()} initialized');
  }
}

/// قاعدة لجميع الصفحات في التطبيق
abstract class BaseView<T> extends GetView<T> {
  const BaseView({super.key});
}

/// قاعدة للصفحات التي تحتفظ بحالة المتحكم
abstract class StatefulView<T extends GetxController> extends GetWidget<T> {
  const StatefulView({super.key});
}

/// قاعدة للصفحات المتجاوبة
abstract class ResponsiveView extends GetResponsiveView {
  ResponsiveView({super.key});

  @override
  Widget? builder() {
    return null;
  }

  @override
  Widget? phone() => null;

  @override
  Widget? tablet() => null;

  @override
  Widget? desktop() => null;
}
