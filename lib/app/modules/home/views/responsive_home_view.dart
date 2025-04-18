import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/cards/custom_card.dart';
import '../controllers/home_controller.dart';

class ResponsiveHomeView extends GetResponsiveView<HomeController> {
  ResponsiveHomeView({super.key});

  @override
  Widget? builder() {
    // Este método se llama si no se define un método específico para el tamaño de pantalla actual
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
        child: Text('Tamaño de pantalla no reconocido: ${screen.screenType}'),
      ),
    );
  }

  @override
  Widget? phone() {
    // Vista para teléfonos (pantallas pequeñas)
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Text(
                      '${'welcome'.tr}, ${controller.userName.value}!',
                      style: Get.textTheme.headlineMedium,
                    )),
              const SizedBox(height: 20),
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'You have pushed the button this many times:',
                      style: Get.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    Obx(() => Text(
                          '${controller.count.value}',
                          style: Get.textTheme.headlineMedium,
                        )),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Increment',
                      onPressed: controller.increment,
                      icon: Icons.add,
                      isFullWidth: true,
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

  @override
  Widget? tablet() {
    // Vista para tablets (pantallas medianas)
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel lateral
            Expanded(
              flex: 1,
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ListTile(
                            title: Text(
                              '${'welcome'.tr}, ${controller.userName.value}!',
                              style: Get.textTheme.titleLarge,
                            ),
                            subtitle: const Text('Tablet View'),
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                          )),
                    const Divider(),
                    ListTile(
                      title: Text('home'.tr),
                      leading: const Icon(Icons.home),
                      selected: true,
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text('settings'.tr),
                      leading: const Icon(Icons.settings),
                      onTap: () => Get.toNamed('/settings'),
                    ),
                    ListTile(
                      title: Text('admin_panel'.tr),
                      leading: const Icon(Icons.admin_panel_settings),
                      onTap: () => Get.toNamed('/admin'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Contenido principal
            Expanded(
              flex: 2,
              child: CustomCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: Get.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.touch_app,
                                  size: 48,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Counter',
                                  style: Get.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Obx(() => Text(
                                      '${controller.count.value}',
                                      style: Get.textTheme.headlineMedium,
                                    )),
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: 'Increment',
                                  onPressed: controller.increment,
                                  icon: Icons.add,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.info,
                                  size: 48,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Responsive View',
                                  style: Get.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Screen Type: ${screen.screenType}',
                                  style: Get.textTheme.bodyLarge,
                                ),
                                Text(
                                  'Width: ${screen.width.toStringAsFixed(0)}',
                                  style: Get.textTheme.bodyLarge,
                                ),
                                Text(
                                  'Height: ${screen.height.toStringAsFixed(0)}',
                                  style: Get.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? desktop() {
    // Vista para escritorio (pantallas grandes)
    return Scaffold(
      body: Row(
        children: [
          // Barra lateral
          Container(
            width: 250,
            color: Get.theme.colorScheme.surface,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Get.theme.colorScheme.primary,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'app_name'.tr,
                        style: Get.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListTile(
                        title: Text(
                          controller.userName.value,
                          style: Get.textTheme.titleMedium,
                        ),
                        subtitle: const Text('Admin'),
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                      )),
                const Divider(),
                ListTile(
                  title: Text('home'.tr),
                  leading: const Icon(Icons.home),
                  selected: true,
                  onTap: () {},
                ),
                ListTile(
                  title: Text('settings'.tr),
                  leading: const Icon(Icons.settings),
                  onTap: () => Get.toNamed('/settings'),
                ),
                ListTile(
                  title: Text('admin_panel'.tr),
                  leading: const Icon(Icons.admin_panel_settings),
                  onTap: () => Get.toNamed('/admin'),
                ),
                const Spacer(),
                const Divider(),
                ListTile(
                  title: Text('logout'.tr),
                  leading: const Icon(Icons.logout),
                  onTap: () {},
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Barra superior
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13), // 0.05 opacity (13/255)
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'dashboard'.tr,
                        style: Get.textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => Get.toNamed('/settings'),
                      ),
                    ],
                  ),
                ),
                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Desktop Dashboard',
                          style: Get.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Panel izquierdo
                              Expanded(
                                flex: 2,
                                child: CustomCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          'Counter',
                                          style: Get.textTheme.titleLarge,
                                        ),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.touch_app,
                                                size: 64,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(height: 24),
                                              Text(
                                                'You have pushed the button this many times:',
                                                style: Get.textTheme.bodyLarge,
                                              ),
                                              const SizedBox(height: 16),
                                              Obx(() => Text(
                                                    '${controller.count.value}',
                                                    style: Get.textTheme.displayMedium,
                                                  )),
                                              const SizedBox(height: 24),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CustomButton(
                                                    text: 'Decrement',
                                                    onPressed: () => controller.count.value--,
                                                    icon: Icons.remove,
                                                    type: ButtonType.secondary,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  CustomButton(
                                                    text: 'Increment',
                                                    onPressed: controller.increment,
                                                    icon: Icons.add,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Panel derecho
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    CustomCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              'Screen Info',
                                              style: Get.textTheme.titleLarge,
                                            ),
                                          ),
                                          const Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _infoRow('Type', '${screen.screenType}'),
                                                _infoRow('Width', '${screen.width.toStringAsFixed(0)}px'),
                                                _infoRow('Height', '${screen.height.toStringAsFixed(0)}px'),
                                                _infoRow('Orientation', MediaQuery.of(Get.context!).orientation == Orientation.landscape ? 'Landscape' : 'Portrait'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    CustomCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              'Actions',
                                              style: Get.textTheme.titleLarge,
                                            ),
                                          ),
                                          const Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                CustomButton(
                                                  text: 'admin_panel'.tr,
                                                  onPressed: () => Get.toNamed('/admin'),
                                                  icon: Icons.admin_panel_settings,
                                                  isFullWidth: true,
                                                ),
                                                const SizedBox(height: 16),
                                                CustomButton(
                                                  text: 'settings'.tr,
                                                  onPressed: () => Get.toNamed('/settings'),
                                                  icon: Icons.settings,
                                                  type: ButtonType.secondary,
                                                  isFullWidth: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Get.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: Get.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
