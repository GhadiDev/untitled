import 'product.dart';

class CartItemWithProduct {
  final int cartId;
  final Product product;

  CartItemWithProduct({required this.cartId, required this.product});

  // Create CartItemWithProduct from Map (from database join query)
  factory CartItemWithProduct.fromMap(Map<String, dynamic> map) {
    return CartItemWithProduct(
      cartId: map['ID'],
      product: Product.fromMap({
        'ID': map['ID'],
        'name': map['name'],
        'price': map['price'],
        'image': map['image'],
        'categoryId': map['categoryId'],
      }),
    );
  }

  // Convert CartItemWithProduct to Map
  Map<String, dynamic> toMap() {
    return {'cartId': cartId, 'product': product.toMap()};
  }

  // Create a copy of CartItemWithProduct with updated fields
  CartItemWithProduct copyWith({int? cartId, Product? product}) {
    return CartItemWithProduct(
      cartId: cartId ?? this.cartId,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'CartItemWithProduct{cartId: $cartId, product: $product}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemWithProduct &&
        other.cartId == cartId &&
        other.product == product;
  }

  @override
  int get hashCode => cartId.hashCode ^ product.hashCode;
}
