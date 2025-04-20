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
  print('��� Running command: $command');

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
  } else {
    print('❌ Unknown command: ${args[0]}');
    printUsage();
  }
}

/// عرض طريقة الاستخدام
void printUsage() {
  print('Usage: dart melos_runner.dart <command> [arguments]');     
  print('');
  print('��� Commands:');
  print('  ��� bootstrap                Install dependencies in all packages');
  print('  ��� run <script>             Run a script defined in melos.yaml');
  print('');
  print('��� Available scripts:');
  print('  ��� build:windows            Build Windows app');
  print('  ��� build:macos              Build macOS app');
  print('  ��� build:linux              Build Linux app');
  print('  ��� build:android            Build Android app');
  print('  ��� build:ios                Build iOS app');
  print('  ��� build:all                Build all platforms');       
  print('  ��� create:installer         Create installer package');  
  print('  ��� github:create-repo       Create GitHub repository');  
  print('  ��� github:sync-config       Sync configuration with GitHub');
  print('  ��� github:publish           Publish release to GitHub'); 
  print('  ��� version:get              Get current version');       
  print('  ��� version:bump             Bump version');
  print('  ��� release:auto             Automatically create, build and publish a release');
  print('');
  print('��� Examples:');
  print('  ��� dart melos_runner.dart bootstrap');
  print('  ��� dart melos_runner.dart run build:windows');
  print('  ��� dart melos_runner.dart run github:publish');
}

/// تنفيذ أمر bootstrap
Future<void> _runBootstrap() async {
  print('��� Installing dependencies in all packages...');

  // تنفيذ pub get في حزمة auto_update_package
  print('\n��� Installing dependencies in auto_update_package...');  
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
  print('\n��� Installing dependencies in core_services_package...');
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
  print('\n��� Installing dependencies in tools_package...');        
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
  print('\n��� Installing dependencies in dev_server_app...');       
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
    case 'version:get':
      await _getVersion();
      break;
    case 'version:bump':
      await _bumpVersion();
      break;
    default:
      print('❌ Unknown script: $scriptName');
      printUsage();
  }
}

/// بناء تطبيق Windows
Future<void> _buildWindows() async {
  print('��� Building Windows app...');

  final result = await Process.run(
    'flutter',
    ['build', 'windows', '--release'],
    workingDirectory: 'apps/dev_server_app',
    runInShell: true,
  );

  print(result.stdout);

  if (result.exitCode != 0) {
    print('❌ Error building Windows app: ${result.stderr}');        
  } else {
    print('✅ Windows app built successfully');
  }
}

/// إنشاء مستودع GitHub
Future<void> _createRepo() async {
  print('��� Creating GitHub repository...');

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
  print('��� Publishing release to GitHub...');

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
  print('��� Creating installer package...');

  // التأكد من وجود مجلد installer
  final installerDir = Directory('apps/dev_server_app/installer');  
  if (!await installerDir.exists()) {
    await installerDir.create(recursive: true);
  }

  // التأكد من وجود مجلد build/installer
  final outputDir = Directory('apps/dev_server_app/build/installer');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  // التأكد من وجود ملف التطبيق
  final appFile = File('apps/dev_server_app/build/windows/x64/runner/Release/dev_server_app.exe');
  if (!await appFile.exists()) {
    print('❌ Application file not found. Please build the application first.');
    print('Run: dart melos_runner.dart run build:windows');
    return;
  }

  // استخدام الأمر المباشر لإنشاء حزمة التثبيت
  print('��� Using Inno Setup directly to create installer...');     

  try {
    // التحقق من وجود Inno Setup
    print('��� Checking for Inno Setup installation...');
    final checkResult = await Process.run(
      'where',
      ['iscc'],
      runInShell: true,
    );

    if (checkResult.exitCode != 0) {
      print('❌ Inno Setup Compiler (iscc) not found in PATH.');     
      print('��� Downloading and installing Inno Setup automatically...');

      // تنزيل وتثبيت Inno Setup تلقائياً
      final downloadDir = Directory('temp');
      if (!await downloadDir.exists()) {
        await downloadDir.create();
      }

      final installerPath = path.join(downloadDir.path, 'innosetup.exe');

      // تنزيل مثبت Inno Setup
      print('��� Downloading Inno Setup installer...');
      final downloadResult = await Process.run(
        'powershell',
        [
          '-Command',
          "(New-Object System.Net.WebClient).DownloadFile('https://jrsoftware.org/download.php/is.exe', '$installerPath')"
        ],
        runInShell: true,
      );

      if (downloadResult.exitCode != 0) {
        print('❌ Error downloading Inno Setup: ${downloadResult.stderr}');
        print('ℹ️ Please install Inno Setup manually from: https://jrsoftware.org/isdl.php');
        return;
      }

      // تثبيت Inno Setup بشكل صامت
      print('��� Installing Inno Setup (this may take a minute)...');
      final installResult = await Process.run(
        installerPath,
        ['/VERYSILENT', '/SUPPRESSMSGBOXES', '/SP-', '/ALLUSERS'],  
        runInShell: true,
      );

      if (installResult.exitCode != 0) {
        print('❌ Error installing Inno Setup: ${installResult.stderr}');
        print('ℹ️ Please install Inno Setup manually from: https://jrsoftware.org/isdl.php');
        return;
      }

      print('✅ Inno Setup installed successfully!');

      // إضافة مجلد Inno Setup إلى PATH
      final innoSetupPath = 'C:\\Program Files (x86)\\Inno Setup 6';

      // التحقق من وجود مجلد Inno Setup
      final innoDir = Directory(innoSetupPath);
      if (!await innoDir.exists()) {
        print('❌ Inno Setup installation directory not found.');    
        print('ℹ️ Please add the Inno Setup directory to your PATH manually.');
        return;
      }

      // محاولة تنفيذ iscc من المسار المباشر
      final isccPath = path.join(innoSetupPath, 'iscc.exe');        
      print('��� Checking if Inno Setup is now available...');       

      // تنظيف مجلد التنزيل المؤقت
      await downloadDir.delete(recursive: true);

      return await _runInnoSetup(isccPath, 'apps/dev_server_app/installer/setup_script.iss');
    }

    print('✅ Inno Setup found: ${checkResult.stdout.trim()}');      

    // إنشاء حزمة التثبيت
    print('��� Building installer package...');
    final result = await Process.run(
      'iscc',
      ['/Q', 'apps/dev_server_app/installer/setup_script.iss'],     
      runInShell: true,
    );

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
  print('��� Building installer package using: $isccPath');

  try {
    final result = await Process.run(
      isccPath,
      ['/Q', scriptPath],
      runInShell: true,
    );

    print(result.stdout);

    if (result.exitCode != 0) {
      print('❌ Error creating installer: ${result.stderr}');        
    } else {
      // التحقق من وجود ملف التثبيت
      final installerFile = File('apps/dev_server_app/build/installer/dev_server-v1.0.0-setup.exe');
      if (await installerFile.exists()) {
        print('✅ Installer created successfully: ${installerFile.path}');
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
  print('��� Getting current version...');

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
  print('��� Bumping version...');

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

/// تنفيذ جميع الخطوات تلقائياً
Future<void> _autoRelease() async {
  print('��� Automatically creating, building and publishing a release...');

  // بناء التطبيق
  await _buildWindows();

  // إنشاء حزمة التثبيت
  await _createInstaller();

  // نشر الإصدار على GitHub
  final result = await Process.run(
    'dart',
    ['lib/github_tools.dart', 'auto', '1.0.0', '1', 'false'],       
    workingDirectory: 'packages/tools_package',
    runInShell: true,
  );

  print(result.stdout);

  if (result.exitCode != 0) {
    print('❌ Error in auto release: ${result.stderr}');
  } else {
    print('✅ Auto release completed successfully');
  }
}
