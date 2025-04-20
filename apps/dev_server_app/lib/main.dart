import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auto_update_package/auto_update_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_page.dart';
import 'about_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة التخزين المحلي
  final prefs = await SharedPreferences.getInstance();

  // تهيئة مدير التحديثات
  final updateManager = UpdateManager(
    configUrl: 'asset:assets/data/app-config.json',
    readStorage: <T>(key) async {
      if (T == String) {
        return prefs.getString(key) as T?;
      } else if (T == bool) {
        return prefs.getBool(key) as T?;
      } else if (T == int) {
        return prefs.getInt(key) as T?;
      } else if (T == double) {
        return prefs.getDouble(key) as T?;
      } else if (T == List<String>) {
        return prefs.getStringList(key) as T?;
      }
      return null;
    },
    writeStorage: (key, value) async {
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else {
        await prefs.setString(key, value.toString());
      }
    },
    logInfo: (message) => debugPrint('INFO: $message'),
    logError: (message, {error}) => debugPrint('ERROR: $message - $error'),
  );

  await updateManager.init();

  runApp(MyApp(updateManager: updateManager));
}

class MyApp extends StatelessWidget {
  final UpdateManager updateManager;

  const MyApp({Key? key, required this.updateManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dev Server',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomePage(updateManager: updateManager),
    );
  }
}

class HomePage extends StatefulWidget {
  final UpdateManager updateManager;

  const HomePage({Key? key, required this.updateManager}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // التحقق من وجود تحديثات عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final hasUpdate = await widget.updateManager.checkForUpdates();

    if (hasUpdate && mounted) {
      // عرض حوار التحديث
      showDialog(
        context: context,
        barrierDismissible: !widget.updateManager.updateRequired.value,
        builder: (context) => UpdateDialog(
          updateManager: widget.updateManager,
          updateInfo: widget.updateManager.latestVersion.value!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Server'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(updateManager: widget.updateManager),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة الترحيب
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'مرحباً بك في تطبيق Dev Server',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<String>(
                      valueListenable: widget.updateManager.currentVersion,
                      builder: (context, version, child) {
                        return Text(
                          'الإصدار الحالي: $version',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // بطاقة التحديثات
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التحديثات',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: widget.updateManager.updateAvailable,
                      builder: (context, available, child) {
                        return Row(
                          children: [
                            Icon(
                              available ? Icons.system_update : Icons.check_circle,
                              color: available ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              available ? 'يوجد تحديث جديد' : 'التطبيق محدث',
                              style: TextStyle(
                                color: available ? Colors.orange : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _checkForUpdates,
                      icon: const Icon(Icons.refresh),
                      label: const Text('التحقق من وجود تحديثات'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // بطاقة الإعدادات
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(updateManager: widget.updateManager),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Icon(Icons.settings),
                      SizedBox(width: 16),
                      Text('الإعدادات', style: TextStyle(fontSize: 16)),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // بطاقة حول التطبيق
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(updateManager: widget.updateManager),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline),
                      SizedBox(width: 16),
                      Text('حول التطبيق', style: TextStyle(fontSize: 16)),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
