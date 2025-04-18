import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import 'dashboard_view.dart';
import 'users_view.dart';
import 'products_view.dart';
import 'orders_view.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_panel'.tr),
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) => controller.currentIndex.value = index,
        children: const [
          DashboardView(),
          UsersView(),
          ProductsView(),
          OrdersView(),
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard),
                label: 'dashboard'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people),
                label: 'users'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory),
                label: 'products'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_cart),
                label: 'orders'.tr,
              ),
            ],
          )),
    );
  }
}
