import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/cards/custom_card.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Settings
            CustomCard(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'theme'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => SwitchListTile(
                        title: Text('dark_mode'.tr),
                        value: controller.isDarkMode.value,
                        onChanged: (value) => controller.toggleTheme(),
                        secondary: Icon(
                          controller.isDarkMode.value
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                      )),
                ],
              ),
            ),

            // Language Settings
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'language'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.languageManager.availableLanguages.length,
                    itemBuilder: (context, index) {
                      final language = controller.languageManager.availableLanguages[index];
                      return Obx(() => RadioListTile<String>(
                            title: Text(language['name']!),
                            value: language['name']!,
                            groupValue: controller.currentLanguage.value,
                            onChanged: (value) => controller.changeLanguageOld(
                              language['code']!,
                              language['country']!,
                            ),
                          ));
                    },
                  ),
                ],
              ),
            ),

            // Updates Settings
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'updates'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.system_update),
                    title: Text('check_for_updates'.tr),
                    subtitle: Obx(() => Text(
                      '${'current_version'.tr}: ${controller.updateManager.currentVersion.value}',
                    )),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => controller.checkForUpdates(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
