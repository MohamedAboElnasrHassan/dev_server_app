// استيراد المكتبات اللازمة فقط
import '../../../core/database/base_repository.dart';
import '../models/user_model.dart';

class UserRepositorySQLite extends BaseRepository<UserModel> {
  @override
  String get tableName => 'users';

  @override
  UserModel fromMap(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }

  /// إضافة مستخدم جديد
  Future<int> addUser(UserModel user) async {
    // التحقق من عدم وجود مستخدم بنفس البريد الإلكتروني
    final existingUsers = await search(user.email, ['email']);
    if (existingUsers.isNotEmpty) {
      throw Exception('البريد الإلكتروني مستخدم بالفعل');
    }

    return await add(user.toMap());
  }

  /// تحديث مستخدم
  Future<int> updateUser(UserModel user) async {
    if (user.id == null) {
      throw Exception('معرف المستخدم غير موجود');
    }

    // التحقق من عدم وجود مستخدم آخر بنفس البريد الإلكتروني
    final existingUsers = await search(user.email, ['email']);
    if (existingUsers.isNotEmpty && existingUsers.first.id != user.id) {
      throw Exception('البريد الإلكتروني مستخدم بالفعل');
    }

    return await update(user.id!, user.toMap()..remove('id'));
  }

  /// البحث عن مستخدم بواسطة البريد الإلكتروني
  Future<UserModel?> findByEmail(String email) async {
    final users = await search(email, ['email']);
    if (users.isEmpty) return null;
    return users.first;
  }

  /// التحقق من صحة بيانات تسجيل الدخول
  Future<UserModel?> authenticate(String email, String password) async {
    final user = await findByEmail(email);
    if (user == null) return null;

    // في الإنتاج، يجب استخدام تشفير كلمة المرور
    if (user.password != password) return null;

    return user;
  }

  /// الحصول على المستخدمين حسب الدور
  Future<List<UserModel>> getUsersByRole(String role) async {
    final allUsers = await getAll();
    return allUsers.where((user) => user.hasRole(role)).toList();
  }
}
