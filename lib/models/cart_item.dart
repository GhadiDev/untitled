class CartItem {
  final int? id;
  final int productId;

  CartItem({this.id, required this.productId});

  // Create CartItem from Map (from database)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(id: map['ID'], productId: map['product_id']);
  }

  // Convert CartItem to Map (for database)
  Map<String, dynamic> toMap() {
    return {'ID': id, 'product_id': productId};
  }

  // Create a copy of CartItem with updated fields
  CartItem copyWith({int? id, int? productId}) {
    return CartItem(id: id ?? this.id, productId: productId ?? this.productId);
  }

  @override
  String toString() {
    return 'CartItem{id: $id, productId: $productId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id && other.productId == productId;
  }

  @override
  int get hashCode => id.hashCode ^ productId.hashCode;
}
