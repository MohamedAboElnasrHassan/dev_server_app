import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/auth_manager_sqlite.dart';

class AdminController extends GetxController {
  final AuthManagerSQLite _authManager = Get.find<AuthManagerSQLite>();

  // بيانات المستخدم
  final userName = 'Admin'.obs;

  // القسم الحالي
  final currentSection = 'dashboard'.obs;

  // إحصائيات لوحة القيادة
  final totalUsers = 0.obs;
  final totalProducts = 0.obs;
  final totalOrders = 0.obs;
  final totalRevenue = 0.0.obs;

  // الطلبات الأخيرة
  final recentOrders = <Map<String, dynamic>>[].obs;

  // المستخدمين
  final users = <Map<String, dynamic>>[].obs;

  // المنتجات
  final products = <Map<String, dynamic>>[].obs;

  // الطلبات
  final orders = <Map<String, dynamic>>[].obs;
  final filteredOrders = <Map<String, dynamic>>[].obs;
  final orderStatusFilter = 'all'.obs;

  // الإحصائيات
  final statisticsPeriod = 'month'.obs;
  final periodRevenue = 0.0.obs;
  final periodOrders = 0.obs;
  final periodNewUsers = 0.obs;
  final periodNewProducts = 0.obs;
  final topSellingProducts = <Map<String, dynamic>>[].obs;

  // الإعدادات
  final notificationsEnabled = true.obs;
  final autoUpdatesEnabled = true.obs;
  final maintenanceModeEnabled = false.obs;
  final twoFactorAuthEnabled = false.obs;
  final secureLoginEnabled = true.obs;

  // متغيرات إضافية من الكود القديم
  final currentIndex = 0.obs;
  final pageController = PageController();
  final userCount = 0.obs;
  final productCount = 0.obs;
  final orderCount = 0.obs;
  final revenueAmount = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    userName.value = _authManager.userName;
    loadDashboardData();
    loadUsers();
    loadProducts();
    loadOrders();
    loadStatistics();
    fetchDashboardData(); // من الكود القديم
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// تغيير القسم الحالي
  void changeSection(String section) {
    currentSection.value = section;
  }

  /// تحميل بيانات لوحة القيادة
  void loadDashboardData() {
    // محاكاة تحميل البيانات
    totalUsers.value = 1250;
    totalProducts.value = 432;
    totalOrders.value = 789;
    totalRevenue.value = 45678.90;

    // محاكاة الطلبات الأخيرة
    recentOrders.value = [
      {
        'id': 1001,
        'date': '2023-05-15',
        'status': 'Completed',
        'total': 125.50,
      },
      {
        'id': 1002,
        'date': '2023-05-14',
        'status': 'Processing',
        'total': 89.99,
      },
      {
        'id': 1003,
        'date': '2023-05-13',
        'status': 'Pending',
        'total': 210.75,
      },
      {
        'id': 1004,
        'date': '2023-05-12',
        'status': 'Completed',
        'total': 45.25,
      },
      {
        'id': 1005,
        'date': '2023-05-11',
        'status': 'Cancelled',
        'total': 78.50,
      },
    ];
  }

  /// تحميل المستخدمين
  void loadUsers() {
    // محاكاة تحميل المستخدمين
    users.value = [
      {
        'id': 1,
        'name': 'أحمد محمد',
        'email': 'ahmed@example.com',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'role': 'admin',
      },
      {
        'id': 2,
        'name': 'سارة أحمد',
        'email': 'sara@example.com',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'role': 'user',
      },
      {
        'id': 3,
        'name': 'محمد علي',
        'email': 'mohamed@example.com',
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'role': 'user',
      },
      {
        'id': 4,
        'name': 'فاطمة حسن',
        'email': 'fatima@example.com',
        'avatar': 'https://i.pravatar.cc/150?img=10',
        'role': 'user',
      },
      {
        'id': 5,
        'name': 'خالد عبدالله',
        'email': 'khaled@example.com',
        'avatar': 'https://i.pravatar.cc/150?img=12',
        'role': 'editor',
      },
    ];
  }

  /// تحميل المنتجات
  void loadProducts() {
    // محاكاة تحميل المنتجات
    products.value = [
      {
        'id': 1,
        'name': 'هاتف ذكي',
        'price': 599.99,
        'image': 'https://via.placeholder.com/300x200?text=Smartphone',
        'category': 'electronics',
      },
      {
        'id': 2,
        'name': 'حاسوب محمول',
        'price': 999.99,
        'image': 'https://via.placeholder.com/300x200?text=Laptop',
        'category': 'electronics',
      },
      {
        'id': 3,
        'name': 'سماعات لاسلكية',
        'price': 149.99,
        'image': 'https://via.placeholder.com/300x200?text=Headphones',
        'category': 'electronics',
      },
      {
        'id': 4,
        'name': 'ساعة ذكية',
        'price': 249.99,
        'image': 'https://via.placeholder.com/300x200?text=Smartwatch',
        'category': 'electronics',
      },
      {
        'id': 5,
        'name': 'كاميرا رقمية',
        'price': 449.99,
        'image': 'https://via.placeholder.com/300x200?text=Camera',
        'category': 'electronics',
      },
      {
        'id': 6,
        'name': 'قميص رجالي',
        'price': 39.99,
        'image': 'https://via.placeholder.com/300x200?text=Shirt',
        'category': 'clothing',
      },
    ];
  }

  /// تحميل الطلبات
  void loadOrders() {
    // محاكاة تحميل الطلبات
    orders.value = [
      {
        'id': 1001,
        'date': '2023-05-15',
        'customer': 'أحمد محمد',
        'status': 'Completed',
        'total': 125.50,
      },
      {
        'id': 1002,
        'date': '2023-05-14',
        'customer': 'سارة أحمد',
        'status': 'Processing',
        'total': 89.99,
      },
      {
        'id': 1003,
        'date': '2023-05-13',
        'customer': 'محمد علي',
        'status': 'Pending',
        'total': 210.75,
      },
      {
        'id': 1004,
        'date': '2023-05-12',
        'customer': 'فاطمة حسن',
        'status': 'Completed',
        'total': 45.25,
      },
      {
        'id': 1005,
        'date': '2023-05-11',
        'customer': 'خالد عبدالله',
        'status': 'Cancelled',
        'total': 78.50,
      },
    ];

    // تحديث الطلبات المفلترة
    filteredOrders.value = orders;
  }

  /// تحميل الإحصائيات
  void loadStatistics() {
    // محاكاة تحميل الإحصائيات
    periodRevenue.value = 12345.67;
    periodOrders.value = 123;
    periodNewUsers.value = 45;
    periodNewProducts.value = 12;

    // محاكاة المنتجات الأكثر مبيعًا
    topSellingProducts.value = [
      {
        'id': 1,
        'name': 'هاتف ذكي',
        'image': 'https://via.placeholder.com/300x200?text=Smartphone',
        'sold': 45,
        'revenue': 26999.55,
      },
      {
        'id': 2,
        'name': 'حاسوب محمول',
        'image': 'https://via.placeholder.com/300x200?text=Laptop',
        'sold': 32,
        'revenue': 31999.68,
      },
      {
        'id': 3,
        'name': 'سماعات لاسلكية',
        'image': 'https://via.placeholder.com/300x200?text=Headphones',
        'sold': 78,
        'revenue': 11699.22,
      },
      {
        'id': 4,
        'name': 'ساعة ذكية',
        'image': 'https://via.placeholder.com/300x200?text=Smartwatch',
        'sold': 54,
        'revenue': 13499.46,
      },
      {
        'id': 5,
        'name': 'كاميرا رقمية',
        'image': 'https://via.placeholder.com/300x200?text=Camera',
        'sold': 21,
        'revenue': 9449.79,
      },
    ];
  }

  /// تسجيل الخروج
  void logout() async {
    await _authManager.logout();
    Get.offAllNamed('/login');
  }

  /// عرض تفاصيل الطلب
  void viewOrderDetails(int orderId) {
    Get.toNamed('/admin/orders/$orderId');
  }

  /// إضافة مستخدم جديد
  void addNewUser() {
    Get.toNamed('/admin/users/add');
  }

  /// تعديل مستخدم
  void editUser(int userId) {
    Get.toNamed('/admin/users/edit/$userId');
  }

  /// حذف مستخدم
  void deleteUser(int userId) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text('delete_user_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // محاكاة حذف المستخدم
              users.removeWhere((user) => user['id'] == userId);
              Get.snackbar(
                'success'.tr,
                'user_deleted'.tr,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  /// عرض تفاصيل المستخدم
  void viewUserDetails(int userId) {
    Get.toNamed('/admin/users/$userId');
  }

  /// إضافة منتج جديد
  void addNewProduct() {
    Get.toNamed('/admin/products/add');
  }

  /// تعديل منتج
  void editProduct(int productId) {
    Get.toNamed('/admin/products/edit/$productId');
  }

  /// حذف منتج
  void deleteProduct(int productId) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text('delete_product_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // محاكاة حذف المنتج
              products.removeWhere((product) => product['id'] == productId);
              Get.snackbar(
                'success'.tr,
                'product_deleted'.tr,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  /// البحث في الطلبات
  void searchOrders(String query) {
    if (query.isEmpty) {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders.where((order) {
        return order['id'].toString().contains(query) ||
               order['customer'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  /// تصفية الطلبات حسب الحالة
  void filterOrdersByStatus(String? status) {
    if (status != null) {
      orderStatusFilter.value = status;

      if (status == 'all') {
        filteredOrders.value = orders;
      } else {
        filteredOrders.value = orders.where((order) {
          return order['status'].toString().toLowerCase() == status.toLowerCase();
        }).toList();
      }
    }
  }

  /// تغيير فترة الإحصائيات
  void changeStatisticsPeriod(String? period) {
    if (period != null) {
      statisticsPeriod.value = period;

      // محاكاة تحديث الإحصائيات حسب الفترة
      switch (period) {
        case 'day':
          periodRevenue.value = 1234.56;
          periodOrders.value = 12;
          periodNewUsers.value = 5;
          periodNewProducts.value = 2;
          break;
        case 'week':
          periodRevenue.value = 5678.90;
          periodOrders.value = 45;
          periodNewUsers.value = 15;
          periodNewProducts.value = 5;
          break;
        case 'month':
          periodRevenue.value = 12345.67;
          periodOrders.value = 123;
          periodNewUsers.value = 45;
          periodNewProducts.value = 12;
          break;
        case 'year':
          periodRevenue.value = 123456.78;
          periodOrders.value = 1234;
          periodNewUsers.value = 456;
          periodNewProducts.value = 123;
          break;
      }
    }
  }

  /// تفعيل/تعطيل الإشعارات
  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
  }

  /// تفعيل/تعطيل التحديثات التلقائية
  void toggleAutoUpdates(bool enabled) {
    autoUpdatesEnabled.value = enabled;
  }

  /// تفعيل/تعطيل وضع الصيانة
  void toggleMaintenanceMode(bool enabled) {
    maintenanceModeEnabled.value = enabled;
  }

  /// تفعيل/تعطيل المصادقة الثنائية
  void toggleTwoFactorAuth(bool enabled) {
    twoFactorAuthEnabled.value = enabled;
  }

  /// تفعيل/تعطيل تسجيل الدخول الآمن
  void toggleSecureLogin(bool enabled) {
    secureLoginEnabled.value = enabled;
  }

  /// تغيير كلمة المرور
  void changePassword() {
    Get.toNamed('/admin/change-password');
  }

  /// حفظ الإعدادات
  void saveSettings() {
    Get.snackbar(
      'success'.tr,
      'settings_saved'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// من الكود القديم
  void changePage(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// من الكود القديم
  void fetchDashboardData() {
    isLoading.value = true;
    // محاكاة استدعاء API
    Future.delayed(const Duration(seconds: 2), () {
      userCount.value = 125;
      productCount.value = 48;
      orderCount.value = 37;
      revenueAmount.value = 12580.50;
      isLoading.value = false;
    });
  }
}
