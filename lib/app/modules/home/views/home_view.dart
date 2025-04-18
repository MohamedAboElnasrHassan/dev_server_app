import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/cards/custom_card.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : Text(
                      '${'welcome'.tr}, ${controller.userName.value}!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )),
              const SizedBox(height: 20),
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'You have pushed the button this many times:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    Obx(() => Text(
                          '${controller.count.value}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        )),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Increment',
                      onPressed: controller.increment,
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'admin_panel'.tr,
                onPressed: () => Get.toNamed('/admin'),
                type: ButtonType.secondary,
                isFullWidth: true,
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Persistent Counter',
                onPressed: () => Get.toNamed('/persistent-counter'),
                type: ButtonType.secondary,
                isFullWidth: true,
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Responsive View',
                onPressed: () => Get.toNamed('/responsive-home'),
                type: ButtonType.secondary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
