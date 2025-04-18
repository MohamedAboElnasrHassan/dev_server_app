import 'dart:io';
import 'dart:convert';

/// تشغيل flutter analyze للتحقق من عدم وجود أخطاء
Future<bool> runFlutterAnalyze() async {
  print('=== 🔍 Running Flutter Analyze ===');
  
  try {
    final result = await Process.run('flutter', ['analyze']);
    
    if (result.exitCode == 0) {
      print('✅ Flutter analyze completed successfully');
      return true;
    } else {
      print('⚠️ Flutter analyze found issues:');
      print(result.stdout);
      print(result.stderr);
      
      // سؤال المستخدم إذا كان يريد الاستمرار
      print('Continue despite analysis issues? (y/n)');
      final response = stdin.readLineSync()?.trim().toLowerCase();
      return response == 'y' || response == 'yes';
    }
  } catch (e) {
    print('⚠️ Warning: Could not run Flutter analyze: $e');
    return true; // الاستمرار في حالة الخطأ
  }
}

/// عرض قائمة تفاعلية
Future<void> showInteractiveMenu() async {
  print('=== 🛠️ Dev Server Tools - Interactive Menu ===');
  print('');
  print('1. Sync configuration');
  print('2. Build app');
  print('3. Create new release');
  print('4. Publish release');
  print('5. Set GitHub token');
  print('6. Auto (create, build, publish)');
  print('0. Exit');
  print('');
  print('Enter your choice (0-6):');
  
  final choice = stdin.readLineSync()?.trim();
  
  switch (choice) {
    case '1':
      await syncConfig();
      break;
    case '2':
      print('\nSelect platform:');
      print('1. Windows');
      print('2. macOS');
      print('3. Linux');
      print('4. All');
      print('Enter platform (1-4):');
      
      final platformChoice = stdin.readLineSync()?.trim();
      String platform;
      
      switch (platformChoice) {
        case '1':
          platform = 'windows';
          break;
        case '2':
          platform = 'macos';
          break;
        case '3':
          platform = 'linux';
          break;
        case '4':
          platform = 'all';
          break;
        default:
          print('❌ Invalid choice');
          return;
      }
      
      await buildApp(platform);
      break;
    case '3':
      print('\nEnter version (e.g. 1.0.2):');
      final version = stdin.readLineSync()?.trim();
      
      print('Enter build number (e.g. 3):');
      final buildNumber = stdin.readLineSync()?.trim();
      
      print('Is this update required? (y/n):');
      final isRequiredInput = stdin.readLineSync()?.trim().toLowerCase();
      final isRequired = isRequiredInput == 'y' || isRequiredInput == 'yes';
      
      if (version != null && version.isNotEmpty && buildNumber != null && buildNumber.isNotEmpty) {
        await createRelease(version, buildNumber, isRequired);
      } else {
        print('❌ Invalid input');
      }
      break;
    case '4':
      print('\nEnter version (e.g. 1.0.2):');
      final version = stdin.readLineSync()?.trim();
      
      print('Enter build number (e.g. 3):');
      final buildNumber = stdin.readLineSync()?.trim();
      
      print('Is this update required? (y/n):');
      final isRequiredInput = stdin.readLineSync()?.trim().toLowerCase();
      final isRequired = isRequiredInput == 'y' || isRequiredInput == 'yes';
      
      if (version != null && version.isNotEmpty && buildNumber != null && buildNumber.isNotEmpty) {
        await publishRelease(version, buildNumber, isRequired: isRequired);
      } else {
        print('❌ Invalid input');
      }
      break;
    case '5':
      print('\nEnter GitHub token:');
      final token = stdin.readLineSync()?.trim();
      
      if (token != null && token.isNotEmpty) {
        await setGitHubToken(token);
      } else {
        print('❌ Invalid token');
      }
      break;
    case '6':
      print('\nEnter version (e.g. 1.0.2):');
      final version = stdin.readLineSync()?.trim();
      
      print('Enter build number (e.g. 3):');
      final buildNumber = stdin.readLineSync()?.trim();
      
      print('Is this update required? (y/n):');
      final isRequiredInput = stdin.readLineSync()?.trim().toLowerCase();
      final isRequired = isRequiredInput == 'y' || isRequiredInput == 'yes';
      
      if (version != null && version.isNotEmpty && buildNumber != null && buildNumber.isNotEmpty) {
        // إنشاء الإصدار
        await createRelease(version, buildNumber, isRequired);
        
        // بناء التطبيق
        await buildApp('all');
        
        // نشر الإصدار
        await publishRelease(version, buildNumber, isRequired: isRequired);
      } else {
        print('❌ Invalid input');
      }
      break;
    case '0':
      print('Exiting...');
      break;
    default:
      print('❌ Invalid choice');
  }
}

// هذه الوظائف سيتم استبدالها بالوظائف الفعلية عند الاستيراد
Future<void> syncConfig() async {}
Future<void> buildApp(String platform) async {}
Future<void> createRelease(String version, String buildNumber, bool isRequired) async {}
Future<void> publishRelease(String version, String buildNumber, {bool isRequired = false}) async {}
Future<void> setGitHubToken(String token) async {}
