import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/auth_manager_sqlite.dart';
import '../app_routes.dart';

/// وسيط لحماية المسارات التي تتطلب دور المسؤول
class AdminMiddleware extends GetMiddleware {
  final authManager = Get.find<AuthManagerSQLite>();

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    // إذا لم يكن لدى المستخدم دور المسؤول
    if (!authManager.hasRole('admin')) {
      // عرض إشعار
      Get.snackbar(
        'تم رفض الوصول',
        'ليس لديك صلاحيات للوصول إلى هذا القسم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // إعادة توجيه إلى الصفحة الرئيسية
      return const RouteSettings(name: Routes.HOME);
    }

    return null;
  }
}
