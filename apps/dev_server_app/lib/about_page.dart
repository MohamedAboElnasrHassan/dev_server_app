import 'package:flutter/material.dart';
import 'package:auto_update_package/auto_update_package.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  final UpdateManager updateManager;

  const AboutPage({super.key, required this.updateManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حول التطبيق'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات التطبيق
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Dev Server',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<String>(
                      valueListenable: updateManager.currentVersion,
                      builder: (context, version, child) {
                        return Center(
                          child: Text(
                            'الإصدار: $version',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تطبيق خادم التطوير مع دعم التحديث التلقائي وتكامل مع GitHub.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // معلومات المطور
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المطور',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Mohamed Abo Elnasr Hassan'),
                    const SizedBox(height: 16),
                    const Text(
                      'الموقع الإلكتروني',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse('https://github.com/MohamedAboElnasrHassan/dev_server');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: const Text(
                        'https://github.com/MohamedAboElnasrHassan/dev_server',
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // معلومات الترخيص
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'الترخيص',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('جميع الحقوق محفوظة © 2023'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
