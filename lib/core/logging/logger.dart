import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../base/app_base.dart';

/// مستويات السجل
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// مدير السجلات
class Logger extends BaseService {
  final bool enableConsoleOutput;
  final bool enableFileOutput;
  final String logFilePath;
  final LogLevel minLevel;

  Logger({
    this.enableConsoleOutput = true,
    this.enableFileOutput = false,
    this.logFilePath = 'app_logs.txt',
    this.minLevel = LogLevel.debug,
  });

  Future<Logger> init() async {
    await initService();

    // إعداد ملف السجل إذا كان التسجيل في ملف مفعلاً
    if (enableFileOutput) {
      try {
        final file = File(logFilePath);
        if (!await file.exists()) {
          await file.create(recursive: true);
        }
      } catch (e) {
        debugPrint('Error creating log file: $e');
      }
    }

    return this;
  }

  /// تسجيل رسالة تصحيح
  void debug(String message, {String? tag}) {
    if (minLevel.index <= LogLevel.debug.index) {
      _log('DEBUG', message, tag: tag);
    }
  }

  /// تسجيل رسالة معلومات
  void info(String message, {String? tag}) {
    if (minLevel.index <= LogLevel.info.index) {
      _log('INFO', message, tag: tag);
    }
  }

  /// تسجيل رسالة تحذير
  void warning(String message, {String? tag}) {
    if (minLevel.index <= LogLevel.warning.index) {
      _log('WARNING', message, tag: tag);
    }
  }

  /// تسجيل رسالة خطأ
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (minLevel.index <= LogLevel.error.index) {
      String logMessage = message;
      if (error != null) {
        logMessage += '\nError: $error';
      }
      if (stackTrace != null) {
        logMessage += '\nStackTrace: $stackTrace';
      }
      _log('ERROR', logMessage, tag: tag);
    }
  }

  /// تسجيل رسالة خطأ فادح
  void fatal(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (minLevel.index <= LogLevel.fatal.index) {
      String logMessage = message;
      if (error != null) {
        logMessage += '\nError: $error';
      }
      if (stackTrace != null) {
        logMessage += '\nStackTrace: $stackTrace';
      }
      _log('FATAL', logMessage, tag: tag);
    }
  }

  /// تسجيل رسالة
  void _log(String level, String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag != null ? '[$tag]' : '';
    final logMessage = '[$timestamp] $level $logTag: $message';

    if (enableConsoleOutput) {
      debugPrint(logMessage);
    }

    if (enableFileOutput) {
      _writeToFile(logMessage);
    }
  }

  /// كتابة رسالة في ملف السجل
  Future<void> _writeToFile(String message) async {
    if (!enableFileOutput) return;

    try {
      final file = File(logFilePath);
      await file.writeAsString('$message\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
  }

  /// الحصول على سجلات من الملف
  Future<List<String>> getLogs({int maxLines = 100}) async {
    if (!enableFileOutput) return [];

    try {
      final file = File(logFilePath);
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      final lines = contents.split('\n');

      if (lines.length <= maxLines) return lines;

      return lines.sublist(lines.length - maxLines);
    } catch (e) {
      debugPrint('Error reading log file: $e');
      return [];
    }
  }

  /// مسح ملف السجل
  Future<void> clearLogs() async {
    if (!enableFileOutput) return;

    try {
      final file = File(logFilePath);
      if (await file.exists()) {
        await file.writeAsString('');
      }
    } catch (e) {
      debugPrint('Error clearing log file: $e');
    }
  }
}
