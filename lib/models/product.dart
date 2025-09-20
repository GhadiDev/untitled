class Product {
  final int? id;
  final String name;
  final double price;
  final String? image;
  final int categoryId;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.image,
    required this.categoryId,
  });

  // Create Product from Map (from database)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['ID'],
      name: map['name'],
      price: map['price'].toDouble(),
      image: map['image'],
      categoryId: map['categoryId'],
    );
  }

  // Convert Product to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'name': name,
      'price': price,
      'image': image,
      'categoryId': categoryId,
    };
  }

  // Create a copy of Product with updated fields
  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? image,
    int? categoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, image: $image, categoryId: $categoryId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.image == image &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    price.hashCode ^
    image.hashCode ^
    categoryId.hashCode;
  }
}

