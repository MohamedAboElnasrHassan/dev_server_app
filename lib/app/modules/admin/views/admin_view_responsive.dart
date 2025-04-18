import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

/// واجهة لوحة الإدارة باستخدام GetResponsiveView
/// GetResponsiveView يوفر واجهة متجاوبة مع أحجام الشاشات المختلفة
class AdminViewResponsive extends GetResponsiveView<AdminController> {
  AdminViewResponsive({super.key});

  @override
  Widget? desktop() {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_panel'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Row(
        children: [
          // القائمة الجانبية
          _buildSidebar(),

          // المحتوى الرئيسي
          Expanded(
            child: Obx(() => _buildContent()),
          ),
        ],
      ),
    );
  }

  @override
  Widget? tablet() {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_panel'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: _buildSidebar(),
      ),
      body: Obx(() => _buildContent()),
    );
  }

  @override
  Widget? phone() {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_panel'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: _buildSidebar(),
      ),
      body: Obx(() => _buildContent()),
    );
  }

  /// بناء القائمة الجانبية
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Get.theme.colorScheme.surface,
      child: Column(
        children: [
          // معلومات المستخدم
          Container(
            padding: const EdgeInsets.all(16),
            color: Get.theme.colorScheme.primaryContainer,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://via.placeholder.com/80'),
                ),
                const SizedBox(height: 16),
                Obx(() => Text(
                  controller.userName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const SizedBox(height: 4),
                Text('admin'.tr),
              ],
            ),
          ),

          // عناصر القائمة
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  title: 'dashboard'.tr,
                  isSelected: controller.currentSection.value == 'dashboard',
                  onTap: () => controller.changeSection('dashboard'),
                ),
                _buildNavItem(
                  icon: Icons.people,
                  title: 'users'.tr,
                  isSelected: controller.currentSection.value == 'users',
                  onTap: () => controller.changeSection('users'),
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag,
                  title: 'products'.tr,
                  isSelected: controller.currentSection.value == 'products',
                  onTap: () => controller.changeSection('products'),
                ),
                _buildNavItem(
                  icon: Icons.shopping_cart,
                  title: 'orders'.tr,
                  isSelected: controller.currentSection.value == 'orders',
                  onTap: () => controller.changeSection('orders'),
                ),
                _buildNavItem(
                  icon: Icons.bar_chart,
                  title: 'statistics'.tr,
                  isSelected: controller.currentSection.value == 'statistics',
                  onTap: () => controller.changeSection('statistics'),
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  title: 'settings'.tr,
                  isSelected: controller.currentSection.value == 'settings',
                  onTap: () => controller.changeSection('settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر القائمة
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Get.theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Get.theme.colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        onTap();
        // إغلاق الدرج في حالة الهاتف أو الجهاز اللوحي
        if (screen.isPhone || screen.isTablet) {
          Get.back();
        }
      },
    );
  }

  /// بناء المحتوى الرئيسي
  Widget _buildContent() {
    switch (controller.currentSection.value) {
      case 'dashboard':
        return _buildDashboard();
      case 'users':
        return _buildUsers();
      case 'products':
        return _buildProducts();
      case 'orders':
        return _buildOrders();
      case 'statistics':
        return _buildStatistics();
      case 'settings':
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  /// بناء لوحة القيادة
  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'dashboard'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // بطاقات الإحصائيات
          GridView.count(
            crossAxisCount: screen.isDesktop ? 4 : (screen.isTablet ? 2 : 1),
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.people,
                title: 'total_users'.tr,
                value: '${controller.totalUsers.value}',
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.shopping_bag,
                title: 'total_products'.tr,
                value: '${controller.totalProducts.value}',
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.shopping_cart,
                title: 'total_orders'.tr,
                value: '${controller.totalOrders.value}',
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.attach_money,
                title: 'total_revenue'.tr,
                value: '\$${controller.totalRevenue.value.toStringAsFixed(2)}',
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // الطلبات الأخيرة
          Text(
            'recent_orders'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: controller.recentOrders.isEmpty
                ? Center(child: Text('no_recent_orders'.tr))
                : ListView.builder(
                    itemCount: controller.recentOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.recentOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('Order #${order['id']}'),
                          subtitle: Text('${order['date']} - ${order['status']}'),
                          trailing: Text(
                            '\$${order['total']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => controller.viewOrderDetails(order['id']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة إحصائية
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قسم المستخدمين
  Widget _buildUsers() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'users'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // زر إضافة مستخدم جديد
          ElevatedButton.icon(
            onPressed: controller.addNewUser,
            icon: const Icon(Icons.add),
            label: Text('add_new_user'.tr),
          ),

          const SizedBox(height: 16),

          // جدول المستخدمين
          Expanded(
            child: controller.users.isEmpty
                ? Center(child: Text('no_users'.tr))
                : ListView.builder(
                    itemCount: controller.users.length,
                    itemBuilder: (context, index) {
                      final user = controller.users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['avatar'] != null
                                ? NetworkImage(user['avatar'])
                                : null,
                            child: user['avatar'] == null
                                ? Text(user['name'][0])
                                : null,
                          ),
                          title: Text(user['name']),
                          subtitle: Text(user['email']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => controller.editUser(user['id']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => controller.deleteUser(user['id']),
                              ),
                            ],
                          ),
                          onTap: () => controller.viewUserDetails(user['id']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم المنتجات
  Widget _buildProducts() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'products'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // زر إضافة منتج جديد
          ElevatedButton.icon(
            onPressed: controller.addNewProduct,
            icon: const Icon(Icons.add),
            label: Text('add_new_product'.tr),
          ),

          const SizedBox(height: 16),

          // جدول المنتجات
          Expanded(
            child: controller.products.isEmpty
                ? Center(child: Text('no_products'.tr))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screen.isDesktop ? 3 : (screen.isTablet ? 2 : 1),
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // صورة المنتج
                            Expanded(
                              child: product['image'] != null
                                  ? Image.network(
                                      product['image'],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey.shade300,
                                      width: double.infinity,
                                      child: const Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                            // تفاصيل المنتج
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${product['price']}',
                                    style: TextStyle(
                                      color: Get.theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => controller.editProduct(product['id']),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => controller.deleteProduct(product['id']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم الطلبات
  Widget _buildOrders() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // تصفية الطلبات
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'search_orders'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: controller.searchOrders,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: controller.orderStatusFilter.value,
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('all'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text('pending'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'processing',
                    child: Text('processing'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('completed'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('cancelled'.tr),
                  ),
                ],
                onChanged: controller.filterOrdersByStatus,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // جدول الطلبات
          Expanded(
            child: controller.filteredOrders.isEmpty
                ? Center(child: Text('no_orders'.tr))
                : ListView.builder(
                    itemCount: controller.filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('Order #${order['id']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${order['date']}'),
                              Text('${order['customer']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(order['status']),
                                backgroundColor: _getStatusColor(order['status']),
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${order['total']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => controller.viewOrderDetails(order['id']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// الحصول على لون حالة الطلب
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// بناء قسم الإحصائيات
  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'statistics'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // فترة الإحصائيات
          Row(
            children: [
              Text('period'.tr),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: controller.statisticsPeriod.value,
                items: [
                  DropdownMenuItem(
                    value: 'day',
                    child: Text('today'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'week',
                    child: Text('this_week'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'month',
                    child: Text('this_month'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'year',
                    child: Text('this_year'.tr),
                  ),
                ],
                onChanged: controller.changeStatisticsPeriod,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // بطاقات الإحصائيات
          GridView.count(
            crossAxisCount: screen.isDesktop ? 4 : (screen.isTablet ? 2 : 1),
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.attach_money,
                title: 'revenue'.tr,
                value: '\$${controller.periodRevenue.value.toStringAsFixed(2)}',
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.shopping_cart,
                title: 'orders'.tr,
                value: '${controller.periodOrders.value}',
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.people,
                title: 'new_users'.tr,
                value: '${controller.periodNewUsers.value}',
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.shopping_bag,
                title: 'new_products'.tr,
                value: '${controller.periodNewProducts.value}',
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // المنتجات الأكثر مبيعًا
          Text(
            'top_selling_products'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: controller.topSellingProducts.isEmpty
                ? Center(child: Text('no_data'.tr))
                : ListView.builder(
                    itemCount: controller.topSellingProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.topSellingProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: product['image'] != null
                              ? Image.network(
                                  product['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image),
                                ),
                          title: Text(product['name']),
                          subtitle: Text('${product['sold']} ${'units_sold'.tr}'),
                          trailing: Text(
                            '\$${product['revenue']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم الإعدادات
  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // إعدادات النظام
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'system_settings'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // تفعيل الإشعارات
                  SwitchListTile(
                    title: Text('enable_notifications'.tr),
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                  ),

                  // تفعيل التحديثات التلقائية
                  SwitchListTile(
                    title: Text('auto_updates'.tr),
                    value: controller.autoUpdatesEnabled.value,
                    onChanged: controller.toggleAutoUpdates,
                  ),

                  // تفعيل وضع الصيانة
                  SwitchListTile(
                    title: Text('maintenance_mode'.tr),
                    value: controller.maintenanceModeEnabled.value,
                    onChanged: controller.toggleMaintenanceMode,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // إعدادات الأمان
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'security_settings'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // تفعيل المصادقة الثنائية
                  SwitchListTile(
                    title: Text('two_factor_auth'.tr),
                    value: controller.twoFactorAuthEnabled.value,
                    onChanged: controller.toggleTwoFactorAuth,
                  ),

                  // تفعيل تسجيل الدخول الآمن
                  SwitchListTile(
                    title: Text('secure_login'.tr),
                    value: controller.secureLoginEnabled.value,
                    onChanged: controller.toggleSecureLogin,
                  ),

                  // زر تغيير كلمة المرور
                  ListTile(
                    title: Text('change_password'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: controller.changePassword,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // زر حفظ الإعدادات
          Center(
            child: ElevatedButton(
              onPressed: controller.saveSettings,
              child: Text('save_settings'.tr),
            ),
          ),
        ],
      ),
    );
  }
}
