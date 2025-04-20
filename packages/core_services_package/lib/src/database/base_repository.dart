import 'package:get/get.dart';
import 'database_manager.dart';

/// مستودع قاعدة للتعامل مع الكيانات
abstract class BaseRepository<T> {
  final DatabaseManager _databaseManager = Get.find<DatabaseManager>();

  /// اسم الجدول
  String get tableName;

  /// تحويل Map إلى نموذج
  T fromMap(Map<String, dynamic> map);

  /// الحصول على قائمة من الكيانات
  Future<List<T>> getAll({
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final maps = await _databaseManager.query(
      tableName,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// الحصول على كيان بواسطة المعرف
  Future<T?> getById(int id) async {
    final maps = await _databaseManager.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  /// البحث عن كيانات
  Future<List<T>> search(String query, List<String> searchFields) async {
    final whereConditions = searchFields.map((field) => '$field LIKE ?').join(' OR ');
    final whereArgs = List.filled(searchFields.length, '%$query%');

    final maps = await _databaseManager.query(
      tableName,
      where: whereConditions,
      whereArgs: whereArgs,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// إضافة كيان جديد
  Future<int> add(Map<String, dynamic> data) async {
    return await _databaseManager.insert(tableName, data);
  }

  /// تحديث كيان
  Future<int> update(int id, Map<String, dynamic> data) async {
    return await _databaseManager.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// حذف كيان
  Future<int> delete(int id) async {
    return await _databaseManager.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// الحصول على عدد الكيانات
  Future<int> count() async {
    final result = await _databaseManager.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return result.first['count'] as int;
  }

  /// الحصول على كيانات بالتحميل الكسول
  Future<List<T>> getPaginated(int page, int pageSize) async {
    final offset = (page - 1) * pageSize;

    final maps = await _databaseManager.query(
      tableName,
      limit: pageSize,
      offset: offset,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// استعلام مباشر للجدول
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool distinct = false,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await _databaseManager.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
}
