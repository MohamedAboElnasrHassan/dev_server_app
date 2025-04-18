import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import '../base/app_base.dart';
import '../database/database_manager.dart';

/// مدير التخزين باستخدام SQLite
class StorageManager extends BaseService {
  final DatabaseManager _databaseManager = Get.find<DatabaseManager>();
  final String tableName = 'settings';

  StorageManager();

  Future<StorageManager> init() async {
    await initService();
    return this;
  }

  /// حفظ قيمة
  Future<void> write(String key, dynamic value) async {
    final stringValue = value.toString();

    // التحقق من وجود المفتاح
    final existingSettings = await _databaseManager.query(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (existingSettings.isEmpty) {
      // إضافة مفتاح جديد
      await _databaseManager.insert(tableName, {
        'key': key,
        'value': stringValue,
      });
    } else {
      // تحديث مفتاح موجود
      await _databaseManager.update(
        tableName,
        {'value': stringValue},
        where: 'key = ?',
        whereArgs: [key],
      );
    }
  }

  /// قراءة قيمة
  Future<T?> read<T>(String key) async {
    final result = await _databaseManager.query(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final value = result.first['value'] as String;

    // تحويل القيمة إلى النوع المطلوب
    if (T == String) {
      return value as T;
    } else if (T == int) {
      return int.tryParse(value) as T?;
    } else if (T == double) {
      return double.tryParse(value) as T?;
    } else if (T == bool) {
      return (value.toLowerCase() == 'true') as T;
    }

    return null;
  }

  /// التحقق من وجود مفتاح
  Future<bool> hasKey(String key) async {
    final result = await _databaseManager.query(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// حذف قيمة
  Future<void> remove(String key) async {
    await _databaseManager.delete(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// مسح جميع القيم
  Future<void> clear() async {
    await _databaseManager.delete(tableName);
  }

  /// الحصول على جميع المفاتيح
  Future<List<String>> getKeys() async {
    final result = await _databaseManager.query(tableName);
    return result.map((row) => row['key'] as String).toList();
  }

  /// الحصول على جميع القيم
  Future<List<String>> getValues() async {
    final result = await _databaseManager.query(tableName);
    return result.map((row) => row['value'] as String).toList();
  }

  /// حفظ كائن كسلسلة JSON
  Future<void> writeObject<T>(String key, T object) async {
    if (object == null) {
      await remove(key);
      return;
    }

    if (object is Map || object is List) {
      // تحويل الكائن إلى سلسلة JSON
      final jsonString = jsonEncode(object);
      await write(key, jsonString);
    } else {
      throw Exception('Object must be a Map or List');
    }
  }

  /// قراءة كائن من سلسلة JSON
  Future<T?> readObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    final jsonString = await read<String>(key);
    if (jsonString == null) return null;

    try {
      // تحويل السلسلة إلى Map
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// قراءة قائمة من الكائنات من سلسلة JSON
  Future<List<T>?> readList<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    final jsonString = await read<String>(key);
    if (jsonString == null) return null;

    try {
      // تحويل السلسلة إلى List
      final List<dynamic> data = jsonDecode(jsonString);
      return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  /// مراقبة التغييرات على مفتاح
  StreamSubscription<dynamic> listenKey(String key, Function(dynamic) callback) {
    // إنشاء متحكم للبث
    final controller = StreamController<dynamic>();

    // الاستماع للتغييرات باستخدام استطلاع دوري
    Timer? timer;
    String? lastValue;

    void checkForChanges() async {
      final currentValue = await read<String>(key);
      if (currentValue != lastValue) {
        lastValue = currentValue;
        controller.add(currentValue);
      }
    }

    // بدء الاستطلاع الدوري
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      checkForChanges();
    });

    // قراءة القيمة الأولية
    checkForChanges();

    // إنشاء اشتراك
    final subscription = controller.stream.listen(callback);

    // إلغاء المؤقت عند إلغاء الاشتراك
    subscription.onDone(() {
      timer?.cancel();
      controller.close();
    });

    return subscription;
  }
}
