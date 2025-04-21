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

  Future<T?> runAsync<T>(
    Future<T> Function() asyncFunction, {
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

// BaseService se ha movido a base_service.dart

// BaseRepository se ha movido a database/base_repository.dart

/// قاعدة لجميع مزودي البيانات في التطبيق
abstract class BaseProvider extends GetConnect {
  @override
  void onInit() {
    super.onInit();
    printInfo(info: '${runtimeType.toString()} initialized');
  }
}

// BaseView y StatefulView se han movido a widgets/getx_widgets.dart

// ResponsiveView se ha movido a widgets/responsive/responsive_view.dart
