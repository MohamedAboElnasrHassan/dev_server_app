import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../../core/utils/auth_manager_sqlite.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final AuthManagerSQLite _authManager = Get.find<AuthManagerSQLite>();

  final count = 0.obs;
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final userName = 'User'.obs;
  final cartItemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchProducts();
  }

  void increment() => count.value++;

  void fetchUserData() {
    isLoading.value = true;
    // محاكاة استدعاء API
    Future.delayed(const Duration(seconds: 1), () {
      userName.value = _authManager.userName;
      isLoading.value = false;
    });
  }

  /// جلب المنتجات
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final productList = await _productRepository.getAll();
      products.value = productList;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_load_products'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث المنتجات
  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  /// إضافة منتج إلى السلة
  void addToCart(ProductModel product) {
    cartItemCount.value++;
    Get.snackbar(
      'success'.tr,
      'product_added_to_cart'.trParams({'name': product.name}),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// عرض تفاصيل المنتج
  void viewProductDetails(ProductModel product) {
    Get.toNamed('/product/${product.id}', arguments: product);
  }

  /// تسجيل الخروج
  void logout() async {
    await _authManager.logout();
    Get.offAllNamed('/login');
  }
}
