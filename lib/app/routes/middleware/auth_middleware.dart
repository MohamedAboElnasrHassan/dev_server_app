import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/auth_manager_sqlite.dart';
import '../app_routes.dart';

/// وسيط لحماية المسارات التي تتطلب المصادقة
class AuthMiddleware extends GetMiddleware {
  final authManager = Get.find<AuthManagerSQLite>();

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // إذا لم يكن المستخدم مسجل الدخول والمسار ليس تسجيل الدخول أو التسجيل
    if (!authManager.isLoggedIn.value &&
        route != Routes.LOGIN &&
        route != Routes.REGISTER) {
      // إعادة توجيه إلى صفحة تسجيل الدخول
      return const RouteSettings(name: Routes.LOGIN);
    }

    // إذا كان المستخدم مسجل الدخول والمسار هو تسجيل الدخول أو التسجيل
    if (authManager.isLoggedIn.value &&
        (route == Routes.LOGIN || route == Routes.REGISTER)) {
      // إعادة توجيه إلى الصفحة الرئيسية
      return const RouteSettings(name: Routes.HOME);
    }

    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    // يمكنك تعديل الصفحة قبل عرضها
    if (page != null) {
      return GetPage(
        name: page.name,
        page: page.page,
        title: 'مسار محمي: ${page.name}',
        binding: page.binding,
        bindings: page.bindings,
        middlewares: page.middlewares,
        transition: page.transition,
      );
    }
    return page;
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    // يمكنك إضافة روابط إضافية
    return bindings;
  }

  @override
  Widget onPageBuilt(Widget page) {
    // يمكنك تعديل ويدجت الصفحة
    printInfo(info: 'تم بناء الصفحة: ${Get.currentRoute}');
    return page;
  }

  @override
  void onPageDispose() {
    // يمكنك القيام بالتنظيف عند تدمير الصفحة
    printInfo(info: 'تم تدمير الصفحة: ${Get.previousRoute}');
  }
}
