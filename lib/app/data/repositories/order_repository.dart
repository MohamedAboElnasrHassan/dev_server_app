import 'package:get/get.dart';
import '../../../core/database/base_repository.dart';
import '../../../core/database/database_manager.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderRepository extends BaseRepository<OrderModel> {
  final DatabaseManager _databaseManager = Get.find<DatabaseManager>();
  
  @override
  String get tableName => 'orders';
  
  @override
  OrderModel fromMap(Map<String, dynamic> map) {
    return OrderModel.fromMap(map);
  }
  
  /// إضافة طلب جديد مع عناصره
  Future<int> addOrder(OrderModel order) async {
    return await _databaseManager.transaction((txn) async {
      // إضافة الطلب
      final orderId = await txn.insert(tableName, order.toMap());
      
      // إضافة عناصر الطلب
      for (var item in order.items) {
        await txn.insert('order_items', item.copyWith(orderId: orderId).toMap());
      }
      
      return orderId;
    });
  }
  
  /// تحديث حالة الطلب
  Future<int> updateOrderStatus(int orderId, String status) async {
    return await update(
      orderId,
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// الحصول على طلبات المستخدم
  Future<List<OrderModel>> getUserOrders(int userId) async {
    final maps = await query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    
    final orders = maps.map((map) => fromMap(map)).toList();
    
    // تحميل عناصر كل طلب
    for (var order in orders) {
      final items = await getOrderItems(order.id!);
      (order as dynamic).items = items;
    }
    
    return orders;
  }
  
  /// الحصول على عناصر الطلب
  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    final maps = await _databaseManager.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    
    final items = maps.map((map) => OrderItemModel.fromMap(map)).toList();
    
    // تحميل معلومات المنتج لكل عنصر
    for (var i = 0; i < items.length; i++) {
      final productMaps = await _databaseManager.query(
        'products',
        where: 'id = ?',
        whereArgs: [items[i].productId],
        limit: 1,
      );
      
      if (productMaps.isNotEmpty) {
        final product = ProductModel.fromMap(productMaps.first);
        items[i] = items[i].copyWith(
          productName: product.name,
          productImage: product.image,
        );
      }
    }
    
    return items;
  }
  
  /// الحصول على الطلبات حسب الحالة
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final maps = await query(
      tableName,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    
    final orders = maps.map((map) => fromMap(map)).toList();
    
    // تحميل عناصر كل طلب
    for (var order in orders) {
      final items = await getOrderItems(order.id!);
      (order as dynamic).items = items;
    }
    
    return orders;
  }
  
  /// الحصول على إحصائيات الطلبات
  Future<Map<String, dynamic>> getOrderStatistics() async {
    // إجمالي المبيعات
    final totalSalesResult = await _databaseManager.rawQuery(
      'SELECT SUM(total) as total_sales FROM orders',
    );
    final totalSales = totalSalesResult.first['total_sales'] ?? 0.0;
    
    // عدد الطلبات حسب الحالة
    final statusCountResult = await _databaseManager.rawQuery(
      'SELECT status, COUNT(*) as count FROM orders GROUP BY status',
    );
    final statusCount = Map<String, int>.fromEntries(
      statusCountResult.map((row) => MapEntry(row['status'] as String, row['count'] as int)),
    );
    
    // المنتجات الأكثر مبيعًا
    final topProductsResult = await _databaseManager.rawQuery('''
      SELECT p.id, p.name, p.image, SUM(oi.quantity) as total_quantity
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      GROUP BY p.id
      ORDER BY total_quantity DESC
      LIMIT 5
    ''');
    
    return {
      'totalSales': totalSales,
      'statusCount': statusCount,
      'topProducts': topProductsResult,
    };
  }
}
