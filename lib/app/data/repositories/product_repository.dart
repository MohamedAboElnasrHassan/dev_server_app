import '../../../core/database/base_repository.dart';
import '../models/product_model.dart';

class ProductRepository extends BaseRepository<ProductModel> {
  @override
  String get tableName => 'products';
  
  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel.fromMap(map);
  }
  
  /// إضافة منتج جديد
  Future<int> addProduct(ProductModel product) async {
    return await add(product.toMap());
  }
  
  /// تحديث منتج
  Future<int> updateProduct(ProductModel product) async {
    if (product.id == null) {
      throw Exception('معرف المنتج غير موجود');
    }
    
    return await update(product.id!, product.toMap()..remove('id'));
  }
  
  /// الحصول على المنتجات حسب الفئة
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final maps = await query(
      tableName,
      where: 'category = ?',
      whereArgs: [category],
    );
    
    return maps.map((map) => fromMap(map)).toList();
  }
  
  /// البحث عن منتجات
  Future<List<ProductModel>> searchProducts(String query) async {
    return await search(query, ['name', 'description', 'category']);
  }
  
  /// الحصول على المنتجات مرتبة حسب السعر
  Future<List<ProductModel>> getProductsSortedByPrice({bool ascending = true}) async {
    final maps = await query(
      tableName,
      orderBy: 'price ${ascending ? 'ASC' : 'DESC'}',
    );
    
    return maps.map((map) => fromMap(map)).toList();
  }
  
  /// الحصول على المنتجات الأحدث
  Future<List<ProductModel>> getLatestProducts({int limit = 10}) async {
    final maps = await query(
      tableName,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    
    return maps.map((map) => fromMap(map)).toList();
  }
}
