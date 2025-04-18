import '../../../core/database/base_model.dart';
import 'order_item_model.dart';

class OrderModel implements BaseModel {
  final int? id;
  final int userId;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemModel> items;

  OrderModel({
    this.id,
    required this.userId,
    required this.total,
    required this.status,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.items = const [],
  }) :
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'total': total,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['user_id'],
      total: map['total'] is int ? (map['total'] as int).toDouble() : map['total'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['created_at']),
      items: [], // يتم تحميل العناصر بشكل منفصل
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      total: json['total'] is int ? (json['total'] as int).toDouble() : json['total'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
      items: json['items'] != null
          ? List<OrderItemModel>.from(
              json['items'].map((item) => OrderItemModel.fromJson(item)))
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = toMap();
    map['items'] = items.map((item) => item.toJson()).toList();
    return map;
  }

  @override
  OrderModel copyWith({
    int? id,
    int? userId,
    double? total,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
