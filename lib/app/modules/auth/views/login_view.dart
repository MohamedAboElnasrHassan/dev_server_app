import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              label: 'email'.tr,
              hint: 'email'.tr,
              keyboardType: TextInputType.emailAddress,
              onChanged: controller.updateEmail,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'password'.tr,
              hint: 'password'.tr,
              obscureText: true,
              onChanged: controller.updatePassword,
              prefixIcon: const Icon(Icons.lock),
            ),
            const SizedBox(height: 24),
            Obx(() => controller.errorMessage.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : const SizedBox.shrink()),
            Obx(() => CustomButton(
                  text: 'login'.tr,
                  onPressed: controller.login,
                  isLoading: controller.isLoading.value,
                  isFullWidth: true,
                )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: Text('register'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
