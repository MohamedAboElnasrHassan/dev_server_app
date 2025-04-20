import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../base/base_service.dart';
import '../logging/logger.dart';

/// مدير التنقل
class NavigationManager extends BaseService {
  late final Logger _logger;
  final currentRoute = ''.obs;
  final previousRoute = ''.obs;
  final routeHistory = <String>[].obs;
  final arguments = Rx<dynamic>(null);

  Future<NavigationManager> init() async {
    await initService();
    
    // الحصول على مدير السجلات
    _logger = Get.find<Logger>();

    // الاستماع للتغييرات في المسار الحالي
    ever(currentRoute, _onRouteChanged);

    return this;
  }

  /// معالجة تغيير المسار
  void _onRouteChanged(String route) {
    if (route.isNotEmpty) {
      if (currentRoute.value != previousRoute.value) {
        previousRoute.value = currentRoute.value;
      }

      routeHistory.add(route);
      if (routeHistory.length > 20) {
        routeHistory.removeAt(0);
      }

      _logger.info('Navigation: $route');
    }
  }

  /// الانتقال إلى مسار
  Future<T?>? to<T>(
    String route, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    this.arguments.value = arguments;
    currentRoute.value = route;

    return Get.toNamed<T>(
      route,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  /// الانتقال إلى مسار وإزالة المسار السابق
  Future<T?>? off<T>(
    String route, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    this.arguments.value = arguments;
    currentRoute.value = route;

    return Get.offNamed<T>(
      route,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  /// الانتقال إلى مسار وإزالة جميع المسارات السابقة
  Future<T?>? offAll<T>(
    String route, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    routeHistory.clear();
    this.arguments.value = arguments;
    currentRoute.value = route;

    return Get.offAllNamed<T>(
      route,
      arguments: arguments,
      id: id,
      parameters: parameters,
    );
  }

  /// الانتقال إلى مسار وإزالة المسارات السابقة حتى مسار معين
  Future<T?>? offUntil<T>(
    String route,
    String predicate, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    this.arguments.value = arguments;
    currentRoute.value = route;

    return Get.offNamedUntil<T>(
      route,
      ModalRoute.withName(predicate),
      arguments: arguments,
      id: id,
      parameters: parameters,
    );
  }

  /// العودة للمسار السابق
  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {
    if (routeHistory.isNotEmpty) {
      routeHistory.removeLast();
      if (routeHistory.isNotEmpty) {
        currentRoute.value = routeHistory.last;
      }
    }

    Get.back<T>(
      result: result,
      closeOverlays: closeOverlays,
      canPop: canPop,
      id: id,
    );
  }

  /// التحقق من إمكانية العودة
  bool get canGoBack => Get.key.currentState?.canPop() ?? false;

  /// الحصول على المسار الحالي
  String get current => currentRoute.value;

  /// الحصول على المسار السابق
  String get previous => previousRoute.value;

  /// الحصول على الوسائط الحالية
  dynamic get currentArguments => arguments.value;
}
