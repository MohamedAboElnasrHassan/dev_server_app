import '../../../core/database/base_model.dart';

class OrderItemModel implements BaseModel {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final String? productName; // للعرض فقط
  final String? productImage; // للعرض فقط
  
  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.productImage,
  });
  
  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
  
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      productName: map['product_name'],
      productImage: map['product_image'],
    );
  }
  
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'],
      productName: json['product_name'],
      productImage: json['product_image'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    ...toMap(),
    if (productName != null) 'product_name': productName,
    if (productImage != null) 'product_image': productImage,
  };
  
  @override
  OrderItemModel copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? quantity,
    double? price,
    String? productName,
    String? productImage,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
    );
  }
  
  /// حساب المجموع
  double get total => price * quantity;
}
