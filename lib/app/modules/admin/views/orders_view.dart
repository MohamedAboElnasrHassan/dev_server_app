import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/cards/custom_card.dart';
import '../controllers/admin_controller.dart';

class OrdersView extends GetView<AdminController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders'.tr,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          CustomCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'search'.tr,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(index),
                        child: Text('#${index + 1}'),
                      ),
                      title: Text('Order #${1000 + index}'),
                      subtitle: Text('User ${index + 1} - \$${(index + 1) * 25}.99'),
                      trailing: Chip(
                        label: Text(_getStatus(index)),
                        backgroundColor: _getStatusColor(index).withAlpha(51), // 0.2 opacity (51/255)
                        labelStyle: TextStyle(color: _getStatusColor(index)),
                      ),
                      onTap: () {},
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatus(int index) {
    switch (index % 4) {
      case 0:
        return 'Pending';
      case 1:
        return 'Processing';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}
