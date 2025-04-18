import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/cards/custom_card.dart';
// import '../../../../core/widgets/getx_widgets.dart';
import '../controllers/home_controller.dart';

/// Ejemplo de vista que mantiene el estado del controlador
/// incluso cuando se navega fuera y se regresa
class PersistentCounterView extends GetWidget<HomeController> {
  const PersistentCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistent Counter'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Este contador mantiene su valor incluso cuando navegas a otra pantalla',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Contador persistente:'),
                    const SizedBox(height: 10),
                    Obx(() => Text(
                          '${controller.count.value}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        )),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: 'Decrementar',
                          onPressed: () => controller.count.value--,
                          icon: Icons.remove,
                          type: ButtonType.secondary,
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          text: 'Incrementar',
                          onPressed: controller.increment,
                          icon: Icons.add,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Volver a Home',
                onPressed: () => Get.back(),
                type: ButtonType.text,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
