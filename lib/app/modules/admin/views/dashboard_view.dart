import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/cards/custom_card.dart';
import '../controllers/admin_controller.dart';

class DashboardView extends GetView<AdminController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'dashboard'.tr,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      context,
                      'users'.tr,
                      controller.userCount.value.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'products'.tr,
                      controller.productCount.value.toString(),
                      Icons.inventory,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'orders'.tr,
                      controller.orderCount.value.toString(),
                      Icons.shopping_cart,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'revenue'.tr,
                      '\$${controller.revenueAmount.value}',
                      Icons.attach_money,
                      Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'recent_activity'.tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.notifications),
                            ),
                            title: Text('Activity ${index + 1}'),
                            subtitle: Text('Description for activity ${index + 1}'),
                            trailing: Text('${index + 1}h ago'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
