import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;

/// سكربت لتسهيل تشغيل أوامر Melos
void main(List<String> args) async {
  if (args.isEmpty) {
    printUsage();
    return;
  }

  final command = args.join(' ');
  print('🚀 Running command: $command');

  // تنفيذ الأوامر مباشرة بدلاً من استخدام Melos
  if (args[0] == 'bootstrap') {
    await _runBootstrap();
  } else if (args[0] == 'run') {
    if (args.length < 2) {
      print('❌ Missing script name');
      printUsage();
      return;
    }

    final scriptName = args[1];
    await _runScript(scriptName);
  } else if (args[0] == 'analyze') {
    await _analyzeCode();
  } else if (args[0] == 'format') {
    await _formatCode();
  } else if (args[0] == 'clean') {
    await _cleanBuildDir();
  } else {
    print('❌ Unknown command: ${args[0]}');
    printUsage();
  }
}

/// عرض طريقة الاستخدام
void printUsage() {
  print('Usage: dart melos_runner.dart <command> [arguments]');
  print('');
  print('📝 Commands:');
  print('  💾 bootstrap                Install dependencies in all packages');
  print('  🚀 run <script>             Run a script defined in melos.yaml');
  print('  🔍 analyze                  Analyze code in all packages');
  print('  🖌 format                   Format code in all packages');
  print('  🚮 clean                    Clean build directories');
  print('');
  print('📝 Available scripts:');
  print('  💻 build:windows            Build Windows app');
  print('  💻 build:macos              Build macOS app');
  print('  💻 build:linux              Build Linux app');
  print('  💻 build:android            Build Android app');
  print('  💻 build:ios                Build iOS app');
  print('  💻 build:all                Build all platforms');
  print('  💾 create:installer         Create installer package');
  print('  🔗 github:create-repo       Create GitHub repository');
  print('  🔄 github:sync-config       Sync configuration with GitHub');
  print('  📤 github:publish           Publish release to GitHub');
  print('  🔍 version:get              Get current version');
  print('  🔎 version:bump             Bump version');
  print(
    '  🚀 release:auto             Automatically create, build and publish a release',
  );
  print(
    '  🔖 release:tag              Create and push a new version tag',
  );
  print('');
  print('📝 Examples:');
  print('  💾 dart melos_runner.dart bootstrap');
  print('  💻 dart melos_runner.dart run build:windows');
  print('  🔍 dart melos_runner.dart analyze');
  print('  🖌 dart melos_runner.dart format');
  print('  🚮 dart melos_runner.dart clean');
  print('  📤 dart melos_runner.dart run github:publish');
  print('  🔖 dart melos_runner.dart run release:tag');
}

/// تنفيذ أمر bootstrap
Future<void> _runBootstrap() async {
  print('📚 Installing dependencies in all packages...');

  // تنفيذ pub get في حزمة auto_update_package
  print('\n📦 Installing dependencies in auto_update_package...');
  final autoUpdateResult = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: 'packages/auto_update_package',
    runInShell: true,
  );

  if (autoUpdateResult.exitCode != 0) {
    print('❌ Error in auto_update_package: ${autoUpdateResult.stderr}');
  } else {
    print('✅ Dependencies installed in auto_update_package');
  }

  // تنفيذ pub get في حزمة core_services_package
  print('\n📦 Installing dependencies in core_services_package...');
  final coreServicesResult = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: 'packages/core_services_package',
    runInShell: true,
  );

  if (coreServicesResult.exitCode != 0) {
    print('❌ Error in core_services_package: ${coreServicesResult.stderr}');
  } else {
    print('✅ Dependencies installed in core_services_package');
  }

  // تنفيذ pub get في حزمة tools_package
  print('\n📦 Installing dependencies in tools_package...');
  final toolsResult = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: 'packages/tools_package',
    runInShell: true,
  );

  if (toolsResult.exitCode != 0) {
    print('❌ Error in tools_package: ${toolsResult.stderr}');
  } else {
    print('✅ Dependencies installed in tools_package');
  }

  // تنفيذ pub get في التطبيق الرئيسي
  print('\n📦 Installing dependencies in dev_server_app...');
  final appResult = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: 'apps/dev_server_app',
    runInShell: true,
  );

  if (appResult.exitCode != 0) {
    print('❌ Error in dev_server_app: ${appResult.stderr}');
  } else {
    print('✅ Dependencies installed in dev_server_app');
  }

  print('\n✅ Bootstrap completed successfully');
}

/// تحليل الكود في جميع الحزم
Future<void> _analyzeCode() async {
  print('🔍 Analyzing code in all packages...');

  // تحليل حزمة core_services_package
  print('\n🔍 Analyzing core_services_package...');
  final coreServicesResult = await Process.run(
    'flutter',
    ['analyze'],
    workingDirectory: 'packages/core_services_package',
    runInShell: true,
  );

  print(coreServicesResult.stdout);

  if (coreServicesResult.exitCode != 0) {
    print('⚠️ Issues found in core_services_package');
  } else {
    print('✅ No issues found in core_services_package');
  }

  // تحليل حزمة auto_update_package
  print('\n🔍 Analyzing auto_update_package...');
  final autoUpdateResult = await Process.run(
    'flutter',
    ['analyze'],
    workingDirectory: 'packages/auto_update_package',
    runInShell: true,
  );

  print(autoUpdateResult.stdout);

  if (autoUpdateResult.exitCode != 0) {
    print('⚠️ Issues found in auto_update_package');
  } else {
    print('✅ No issues found in auto_update_package');
  }

  // تحليل حزمة tools_package
  print('\n🔍 Analyzing tools_package...');
  final toolsResult = await Process.run(
    'flutter',
    ['analyze'],
    workingDirectory: 'packages/tools_package',
    runInShell: true,
  );

  print(toolsResult.stdout);

  if (toolsResult.exitCode != 0) {
    print('⚠️ Issues found in tools_package');
  } else {
    print('✅ No issues found in tools_package');
  }

  // تحليل التطبيق الرئيسي
  print('\n🔍 Analyzing dev_server_app...');
  final appResult = await Process.run(
    'flutter',
    ['analyze'],
    workingDirectory: 'apps/dev_server_app',
    runInShell: true,
  );

  print(appResult.stdout);

  if (appResult.exitCode != 0) {
    print('⚠️ Issues found in dev_server_app');
  } else {
    print('✅ No issues found in dev_server_app');
  }

  // عرض ملخص
  print('\n📊 Analysis Summary:');
  final hasIssues =
      coreServicesResult.exitCode != 0 ||
      autoUpdateResult.exitCode != 0 ||
      toolsResult.exitCode != 0 ||
      appResult.exitCode != 0;

  if (hasIssues) {
    print('⚠️ Issues found in one or more packages');
  } else {
    print('✅ No issues found in any package');
  }
}

/// تنفيذ سكربت محدد
Future<void> _runScript(String scriptName) async {
  switch (scriptName) {
    case 'build:windows':
      await _buildWindows();
      break;
    case 'build:all':
      await _buildWindows();
      break;
    case 'create:installer':
      await _createInstaller();
      break;
    case 'github:create-repo':
    case 'create:repo':
      await _createRepo();
      break;
    case 'github:publish':
    case 'publish:github':
      await _publishGithub();
      break;
    case 'release:auto':
    case 'auto:release':
      await _autoRelease();
      break;
    case 'release:tag':
    case 'tag:release':
      await _createAndPushTag();
      break;
    case 'version:get':
      await _getVersion();
      break;
    case 'version:bump':
      await _bumpVersion();
      break;
    case 'analyze':
      await _analyzeCode();
      break;
    case 'format':
      await _formatCode();
      break;
    case 'clean':
      await _cleanBuildDir();
      break;
    default:
      print('❌ Unknown script: $scriptName');
      printUsage();
  }
}

/// بناء تطبيق Windows
Future<void> _buildWindows() async {
  print('💻 Building Windows app...');

  // تنظيف المشروع وحذف مجلد ephemeral لتجنب مشاكل الروابط الرمزية
  print('🔄 Cleaning project and removing ephemeral folder...');

  // حذف مجلد ephemeral إذا كان موجودًا
  final ephemeralDir = Directory('apps/dev_server_app/windows/flutter/ephemeral');
  if (await ephemeralDir.exists()) {
    try {
      await ephemeralDir.delete(recursive: true);
      print('✅ Ephemeral folder deleted successfully');
    } catch (e) {
      print('⚠️ Could not delete ephemeral folder: $e');
      print('ℹ️ Trying to continue anyway...');
    }
  }

  // تنظيف المشروع
  print('🔄 Running flutter clean...');
  final cleanResult = await Process.run(
    'flutter',
    ['clean'],
    workingDirectory: 'apps/dev_server_app',
    runInShell: true,
  );

  if (cleanResult.exitCode != 0) {
    print('⚠️ Warning during flutter clean: ${cleanResult.stderr}');
  } else {
    print('✅ Flutter clean completed successfully');
  }

  // إعادة تثبيت التبعيات
  print('🔄 Running flutter pub get...');
  final pubGetResult = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: 'apps/dev_server_app',
    runInShell: true,
  );

  if (pubGetResult.exitCode != 0) {
    print('⚠️ Warning during flutter pub get: ${pubGetResult.stderr}');
  } else {
    print('✅ Flutter pub get completed successfully');
  }

  // بناء التطبيق
  print('💻 Building Windows app...');
  final result = await Process.run(
    'flutter',
    ['build', 'windows', '--release'],
    workingDirectory: 'apps/dev_server_app',
    runInShell: true,
  );

  print(result.stdout);

  if (result.exitCode != 0) {
    print('❌ Error building Windows app: ${result.stderr}');

    // محاولة بديلة باستخدام صلاحيات المسؤول
    print('🔄 Trying alternative build with elevated permissions...');
    final elevatedResult = await Process.run(
      'powershell',
      ['-Command', 'Start-Process cmd -ArgumentList \'/c cd ${Directory.current.path}\\apps\\dev_server_app && flutter build windows --release\' -Verb RunAs -Wait'],
      runInShell: true,
    );

    if (elevatedResult.exitCode != 0) {
      print('❌ Error with elevated build: ${elevatedResult.stderr}');
      return; // الخروج من الدالة في حالة الفشل
    } else {
      print('✅ Windows app built successfully with elevated permissions');
    }
  } else {
    print('✅ Windows app built successfully');
  }

  // التحقق من وجود ملف التطبيق
  final appFile = File('apps/dev_server_app/build/windows/x64/runner/Release/dev_server_app.exe');
  if (await appFile.exists()) {
    print('✅ Application file found at: ${appFile.path}');

    // نسخ الملفات إلى مجلد app_build
    print('💾 Copying build files to app_build directory...');

    // التأكد من وجود مجلد app_build
    final appBuildDir = Directory('app_build');
    if (!await appBuildDir.exists()) {
      await appBuildDir.create(recursive: true);
    }

    // التأكد من وجود مجلد app_build/windows
    final appBuildWindowsDir = Directory('app_build/windows');
    if (!await appBuildWindowsDir.exists()) {
      await appBuildWindowsDir.create(recursive: true);
    }

    try {
      // نسخ ملف التطبيق إلى مجلد app_build/windows
      final targetFile = File('app_build/windows/dev_server_app.exe');
      await appFile.copy(targetFile.path);

      // نسخ الملفات المطلوبة الأخرى (DLLs, data files, etc.)
      final sourceDir = Directory('apps/dev_server_app/build/windows/x64/runner/Release');
      final files = await sourceDir.list().toList();

      for (var entity in files) {
        if (entity is File && entity.path != appFile.path) {
          final fileName = path.basename(entity.path);
          final targetFilePath = 'app_build/windows/$fileName';
          await entity.copy(targetFilePath);
        }
      }

      // نسخ مجلد data إذا كان موجودًا
      final dataDir = Directory('apps/dev_server_app/build/windows/x64/runner/Release/data');
      if (await dataDir.exists()) {
        final targetDataDir = Directory('app_build/windows/data');
        if (!await targetDataDir.exists()) {
          await targetDataDir.create(recursive: true);
        }

        // نسخ محتويات مجلد data
        await _copyDirectory(dataDir.path, targetDataDir.path);
      }

      print('✅ Build files copied to app_build/windows directory successfully');
    } catch (e) {
      print('⚠️ Warning: Could not copy all files to app_build directory: $e');
    }
  } else {
    print('❌ Application file not found. Build may have failed.');
  }
}

/// إنشاء مستودع GitHub
Future<void> _createRepo() async {
  print('🔗 Creating GitHub repository...');

  final result = await Process.run(
    'dart',
    ['lib/github_tools.dart', 'create'],
    workingDirectory: 'packages/tools_package',
    runInShell: true,
  );

  print(result.stdout);

  if (result.exitCode != 0) {
    print('❌ Error creating GitHub repository: ${result.stderr}');
  } else {
    print('✅ GitHub repository created successfully');
  }
}

/// نشر إصدار على GitHub
Future<void> _publishGithub() async {
  print('📤 Publishing release to GitHub...');

  final result = await Process.run(
    'dart',
    ['lib/github_tools.dart', 'publish', '1.0.0', '1'],
    workingDirectory: 'packages/tools_package',
    runInShell: true,
  );

  print(result.stdout);

  if (result.exitCode != 0) {
    print('❌ Error publishing release: ${result.stderr}');
  } else {
    print('✅ Release published successfully');
  }
}

/// إنشاء حزمة تثبيت
Future<void> _createInstaller() async {
  print('💾 Creating installer package...');

  // التأكد من وجود ملف التطبيق (التحقق من مجلد app_build أولاً)
  File appFile;
  final appBuildFile = File('app_build/windows/dev_server_app.exe');

  if (await appBuildFile.exists()) {
    // استخدام الملف من مجلد app_build
    appFile = appBuildFile;
    print('✅ Using application file from app_build directory');
  } else {
    // التحقق من المسار الافتراضي
    appFile = File(
      'apps/dev_server_app/build/windows/x64/runner/Release/dev_server_app.exe',
    );
  }
  if (!await appFile.exists()) {
    print('❌ Application file not found. Attempting to build the application first...');

    // محاولة بناء التطبيق تلقائيًا
    await _buildWindows();

    // التحقق مرة أخرى من وجود ملف التطبيق
    if (!await appFile.exists()) {
      print('❌ Application file still not found after build attempt. Cannot create installer.');
      return;
    } else {
      print('✅ Application built successfully. Proceeding with installer creation.');
    }
  }

  // استخدام الطريقة اليدوية لإنشاء حزمة التثبيت
  print('📍 Using manual Inno Setup method...');
  return await _createInstallerManually();
}

/// إنشاء حزمة تثبيت يدويًا باستخدام Inno Setup
Future<void> _createInstallerManually() async {
  print('📍 Using Inno Setup directly to create installer...');

  // التأكد من وجود مجلد installer
  final installerDir = Directory('apps/dev_server_app/installer');
  if (!await installerDir.exists()) {
    await installerDir.create(recursive: true);
  }

  // التأكد من وجود مجلد app_build/installer
  final outputDir = Directory('app_build/installer');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  // إنشاء مجلد build/installer أيضًا للتوافق مع الكود القديم
  final legacyOutputDir = Directory('apps/dev_server_app/build/installer');
  if (!await legacyOutputDir.exists()) {
    await legacyOutputDir.create(recursive: true);
  }

  try {
    // التحقق من وجود Inno Setup في المسارات المحتملة
    print('🔍 Checking for Inno Setup installation...');

    // قائمة المسارات المحتملة لـ Inno Setup
    final possiblePaths = [
      'C:\\Program Files (x86)\\Inno Setup 6\\iscc.exe',
      'C:\\Program Files\\Inno Setup 6\\iscc.exe',
      'C:\\Program Files (x86)\\Inno Setup 5\\iscc.exe',
      'C:\\Program Files\\Inno Setup 5\\iscc.exe',
    ];

    String? isccPath;

    // التحقق من وجود iscc في المسارات المحتملة
    for (final p in possiblePaths) {
      if (await File(p).exists()) {
        isccPath = p;
        print('✅ Inno Setup found at: $isccPath');
        break;
      }
    }

    // إذا لم يتم العثور على iscc في المسارات المحتملة، نتحقق من PATH
    if (isccPath == null) {
      final checkResult = await Process.run('where', ['iscc'], runInShell: true);

      if (checkResult.exitCode == 0 && checkResult.stdout.toString().trim().isNotEmpty) {
        isccPath = checkResult.stdout.toString().trim().split('\n')[0];
        print('✅ Inno Setup found in PATH: $isccPath');
      }
    }

    // إذا لم يتم العثور على iscc، نطلب من المستخدم تثبيته يدويًا
    if (isccPath == null) {
      print('❌ Inno Setup Compiler (iscc) not found.');
      print('ℹ️ Please install Inno Setup manually from: https://jrsoftware.org/isdl.php');
      print('ℹ️ After installation, please run the command again.');
      return;
    }

    // استخدام iscc لإنشاء حزمة التثبيت
    return await _runInnoSetup(
      isccPath,
      'apps/dev_server_app/installer/setup_script.iss',
    );

    // إنشاء حزمة التثبيت
    print('📦 Building installer package...');
    final result = await Process.run('iscc', [
      '/Q',
      'apps/dev_server_app/installer/setup_script.iss',
    ], runInShell: true);

    print(result.stdout);

    if (result.exitCode != 0) {
      print('❌ Error creating installer: ${result.stderr}');
    } else {
      print('✅ Installer created successfully!');
    }
  } catch (e) {
    print('❌ Error creating installer: $e');
  }
}

/// تنفيذ Inno Setup من مسار محدد
Future<void> _runInnoSetup(String isccPath, String scriptPath) async {
  print('📦 Building installer package using: $isccPath');

  try {
    final result = await Process.run(isccPath, [
      '/Q',
      scriptPath,
    ], runInShell: true);

    print(result.stdout);

    if (result.exitCode != 0) {
      print('❌ Error creating installer: ${result.stderr}');
    } else {
      // التحقق من وجود ملف التثبيت
      // التحقق من المسار الجديد أولاً
      final newInstallerFile = File('app_build/installer/dev_server-v1.0.0-setup.exe');
      final legacyInstallerFile = File('apps/dev_server_app/build/installer/dev_server-v1.0.0-setup.exe');

      if (await newInstallerFile.exists()) {
        print('✅ Installer created successfully in app_build directory: ${newInstallerFile.path}');
      } else if (await legacyInstallerFile.exists()) {
        print('✅ Installer created successfully in legacy directory: ${legacyInstallerFile.path}');

        // نسخ الملف إلى المسار الجديد
        try {
          // التأكد من وجود مجلد app_build/installer
          final appBuildInstallerDir = Directory('app_build/installer');
          if (!await appBuildInstallerDir.exists()) {
            await appBuildInstallerDir.create(recursive: true);
          }

          await legacyInstallerFile.copy(newInstallerFile.path);
        } catch (e) {
          print('⚠️ Warning: Could not copy installer to new path: $e');
        }
      } else {
        print('❌ Installer file not found after compilation.');
      }
    }
  } catch (e) {
    print('❌ Error running Inno Setup: $e');
  }
}

/// الحصول على الإصدار الحالي
Future<void> _getVersion() async {
  print('🔍 Getting current version...');

  try {
    final result = await Process.run(
      'dart',
      ['lib/github_tools.dart', 'version'],
      workingDirectory: 'packages/tools_package',
      runInShell: true,
    );

    print(result.stdout);

    if (result.exitCode != 0) {
      print('❌ Error getting version: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Error getting version: $e');
  }
}

/// زيادة رقم الإصدار
Future<void> _bumpVersion() async {
  print('🔎 Bumping version...');

  try {
    final result = await Process.run(
      'dart',
      ['lib/github_tools.dart', 'bump'],
      workingDirectory: 'packages/tools_package',
      runInShell: true,
    );

    print(result.stdout);

    if (result.exitCode != 0) {
      print('❌ Error bumping version: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Error bumping version: $e');
  }
}

/// تنسيق الكود في جميع الحزم
Future<void> _formatCode() async {
  print('🖌 Formatting code in all packages...');

  // تنسيق حزمة core_services_package
  print('\n🖌 Formatting core_services_package...');
  final coreServicesResult = await Process.run(
    'dart',
    ['format', '.'],
    workingDirectory: 'packages/core_services_package',
    runInShell: true,
  );

  if (coreServicesResult.exitCode != 0) {
    print(
      '⚠️ Issues formatting core_services_package: ${coreServicesResult.stderr}',
    );
  } else {
    print('✅ core_services_package formatted successfully');
  }

  // تنسيق حزمة auto_update_package
  print('\n🖌 Formatting auto_update_package...');
  final autoUpdateResult = await Process.run(
    'dart',
    ['format', '.'],
    workingDirectory: 'packages/auto_update_package',
    runInShell: true,
  );

  if (autoUpdateResult.exitCode != 0) {
    print(
      '⚠️ Issues formatting auto_update_package: ${autoUpdateResult.stderr}',
    );
  } else {
    print('✅ auto_update_package formatted successfully');
  }

  // تنسيق حزمة tools_package
  print('\n🖌 Formatting tools_package...');
  final toolsResult = await Process.run(
    'dart',
    ['format', '.'],
    workingDirectory: 'packages/tools_package',
    runInShell: true,
  );

  if (toolsResult.exitCode != 0) {
    print('⚠️ Issues formatting tools_package: ${toolsResult.stderr}');
  } else {
    print('✅ tools_package formatted successfully');
  }

  // تنسيق التطبيق الرئيسي
  print('\n🖌 Formatting dev_server_app...');
  final appResult = await Process.run(
    'dart',
    ['format', '.'],
    workingDirectory: 'apps/dev_server_app',
    runInShell: true,
  );

  if (appResult.exitCode != 0) {
    print('⚠️ Issues formatting dev_server_app: ${appResult.stderr}');
  } else {
    print('✅ dev_server_app formatted successfully');
  }

  // تنسيق ملفات المستوى الرئيسي
  print('\n🖌 Formatting root files...');
  final rootResult = await Process.run('dart', [
    'format',
    '.',
  ], runInShell: true);

  if (rootResult.exitCode != 0) {
    print('⚠️ Issues formatting root files: ${rootResult.stderr}');
  } else {
    print('✅ Root files formatted successfully');
  }

  // عرض ملخص
  print('\n📊 Formatting Summary:');
  final hasIssues =
      coreServicesResult.exitCode != 0 ||
      autoUpdateResult.exitCode != 0 ||
      toolsResult.exitCode != 0 ||
      appResult.exitCode != 0 ||
      rootResult.exitCode != 0;

  if (hasIssues) {
    print('⚠️ Issues found while formatting one or more packages');
  } else {
    print('✅ All packages formatted successfully');
  }
}

/// تنظيف مجلدات البناء
Future<void> _cleanBuildDir() async {
  print('🚮 Cleaning build directories...');

  // تنظيف مجلد app_build
  print('🚮 Cleaning app_build directory...');
  final appBuildDir = Directory('app_build');
  if (await appBuildDir.exists()) {
    try {
      await appBuildDir.delete(recursive: true);
      print('✅ app_build directory deleted successfully');
    } catch (e) {
      print('❌ Error deleting app_build directory: $e');
    }
  } else {
    print('ℹ️ app_build directory does not exist');
  }

  // تنظيف مجلد build في التطبيق الرئيسي
  print('🚮 Cleaning app build directory...');
  final appBuildDirLegacy = Directory('apps/dev_server_app/build');
  if (await appBuildDirLegacy.exists()) {
    try {
      await appBuildDirLegacy.delete(recursive: true);
      print('✅ app build directory deleted successfully');
    } catch (e) {
      print('❌ Error deleting app build directory: $e');
    }
  } else {
    print('ℹ️ app build directory does not exist');
  }

  // تنظيف مجلد .dart_tool في التطبيق الرئيسي
  print('🚮 Cleaning .dart_tool directories...');
  final dartToolDir = Directory('apps/dev_server_app/.dart_tool');
  if (await dartToolDir.exists()) {
    try {
      await dartToolDir.delete(recursive: true);
      print('✅ app .dart_tool directory deleted successfully');
    } catch (e) {
      print('❌ Error deleting app .dart_tool directory: $e');
    }
  }

  // تنظيف مجلد .dart_tool في الحزم
  for (final packageName in ['core_services_package', 'auto_update_package', 'tools_package']) {
    final packageDartToolDir = Directory('packages/$packageName/.dart_tool');
    if (await packageDartToolDir.exists()) {
      try {
        await packageDartToolDir.delete(recursive: true);
        print('✅ $packageName .dart_tool directory deleted successfully');
      } catch (e) {
        print('❌ Error deleting $packageName .dart_tool directory: $e');
      }
    }
  }

  print('📊 Cleaning Summary:');
  print('✅ Build directories cleaned successfully');
  print('ℹ️ Run "dart melos_runner.dart bootstrap" to reinstall dependencies');
}

/// إنشاء ودفع تاج جديد
Future<void> _createAndPushTag() async {
  print('🔖 Creating and pushing a new version tag...');

  try {
    // الحصول على رقم الإصدار الحالي
    final versionResult = await Process.run(
      'dart',
      ['lib/github_tools.dart', 'version'],
      workingDirectory: 'packages/tools_package',
      runInShell: true,
    );

    String version = '1.0.0';
    if (versionResult.exitCode == 0) {
      final versionOutput = versionResult.stdout.toString();
      print('Version output: $versionOutput');

      // محاولة استخراج رقم الإصدار بعدة طرق
      final appVersionMatch = RegExp(r'App version:\s+([\d\.]+)').firstMatch(versionOutput);

      if (appVersionMatch != null) {
        version = appVersionMatch.group(1) ?? version;
        print('Found version from App version: $version');
      }
    }

    print('🔖 Using version: $version');

    // إنشاء تاج جديد
    print('🔖 Creating tag v$version...');
    final createTagResult = await Process.run(
      'git',
      ['tag', '-a', 'v$version', '-m', 'Release v$version'],
      runInShell: true,
    );

    if (createTagResult.exitCode != 0) {
      print('❌ Error creating tag: ${createTagResult.stderr}');
      return;
    }

    // دفع التاج إلى GitHub
    print('🔖 Pushing tag v$version to GitHub...');
    final pushTagResult = await Process.run(
      'git',
      ['push', 'origin', 'v$version'],
      runInShell: true,
    );

    if (pushTagResult.exitCode != 0) {
      print('❌ Error pushing tag: ${pushTagResult.stderr}');
      return;
    }

    print('✅ Tag v$version created and pushed successfully!');
    print('ℹ️ GitHub Actions will now build and release automatically.');
  } catch (e) {
    print('❌ Error creating and pushing tag: $e');
  }
}

/// نسخ مجلد بشكل متكرر
Future<void> _copyDirectory(String source, String destination) async {
  final sourceDir = Directory(source);
  final destinationDir = Directory(destination);

  if (!await destinationDir.exists()) {
    await destinationDir.create(recursive: true);
  }

  await for (final entity in sourceDir.list(recursive: false)) {
    final newPath = path.join(destination, path.basename(entity.path));

    if (entity is File) {
      await entity.copy(newPath);
    } else if (entity is Directory) {
      await _copyDirectory(entity.path, newPath);
    }
  }
}

/// تنفيذ جميع الخطوات تلقائياً
Future<void> _autoRelease() async {
  print('[INFO] Automatically creating, building and publishing a release...');

  try {
    // بناء التطبيق
    print('💻 Step 1/3: Building Windows application...');
    await _buildWindows();

    // التحقق من نجاح البناء
    final appFile = File('apps/dev_server_app/build/windows/x64/runner/Release/dev_server_app.exe');
    if (!await appFile.exists()) {
      print('❌ Build failed: Application file not found. Cannot proceed with release.');
      return;
    }

    print('✅ Build completed successfully!');

    // إنشاء حزمة التثبيت
    print('💾 Step 2/3: Creating installer package...');
    await _createInstaller();

    // التحقق من نجاح إنشاء حزمة التثبيت
    // التحقق من المسار الجديد أولاً
    final newInstallerFile = File('app_build/installer/dev_server-v1.0.0-setup.exe');
    final legacyInstallerFile = File('apps/dev_server_app/build/installer/dev_server-v1.0.0-setup.exe');

    if (await newInstallerFile.exists()) {
      print('✅ Installer created successfully in app_build directory!');

      // نسخ الملف إلى المسار القديم للتوافق
      if (!await legacyInstallerFile.exists()) {
        try {
          await newInstallerFile.copy(legacyInstallerFile.path);
        } catch (e) {
          print('⚠️ Warning: Could not copy installer to legacy path: $e');
        }
      }
    } else if (await legacyInstallerFile.exists()) {
      print('✅ Installer created successfully in legacy directory!');

      // نسخ الملف إلى المسار الجديد
      try {
        // التأكد من وجود مجلد app_build/installer
        final appBuildInstallerDir = Directory('app_build/installer');
        if (!await appBuildInstallerDir.exists()) {
          await appBuildInstallerDir.create(recursive: true);
        }

        await legacyInstallerFile.copy(newInstallerFile.path);
      } catch (e) {
        print('⚠️ Warning: Could not copy installer to new path: $e');
      }
    } else {
      print('⚠️ Warning: Installer file not found in any location. Will attempt to publish release anyway.');
    }

    // نشر الإصدار على GitHub
    print('🔖 Step 3/3: Publishing release to GitHub...');

    // الحصول على رقم الإصدار الحالي
    final versionResult = await Process.run(
      'dart',
      ['lib/github_tools.dart', 'version'],
      workingDirectory: 'packages/tools_package',
      runInShell: true,
    );

    String version = '1.0.0';
    String buildNumber = '1';

    if (versionResult.exitCode == 0 && versionResult.stdout.toString().contains('Version:')) {
      final versionOutput = versionResult.stdout.toString();
      final versionMatch = RegExp(r'Version:\s+([\d\.]+)\+?(\d+)?').firstMatch(versionOutput);
      if (versionMatch != null) {
        version = versionMatch.group(1) ?? version;
        buildNumber = versionMatch.group(2) ?? buildNumber;
      }
    }

    print('🔖 Using version: $version+$buildNumber');

    final result = await Process.run(
      'dart',
      ['lib/github_tools.dart', 'auto', version, buildNumber, 'false'],
      workingDirectory: 'packages/tools_package',
      runInShell: true,
    );

    print(result.stdout);

    if (result.exitCode != 0) {
      print('❌ Error in auto release: ${result.stderr}');
    } else {
      print('✅ Auto release completed successfully');
    }

    print('🎉 Release process completed! 🎉');
    print('ℹ️ Check GitHub for the published release: https://github.com/MohamedAboElnasrHassan/dev_server/releases');
  } catch (e) {
    print('❌ Error during release process: $e');
    print('ℹ️ Please try running the steps individually:');
    print('  1. dart melos_runner.dart run build:windows');
    print('  2. dart melos_runner.dart run create:installer');
    print('  3. dart melos_runner.dart run github:publish');
  }
}
