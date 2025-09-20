class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  // Create Category from Map (from database)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['ID'], name: map['Name']);
  }

  // Convert Category to Map (for database)
  Map<String, dynamic> toMap() {
    return {'ID': id, 'Name': name};
  }

  // Create a copy of Category with updated fields
  Category copyWith({int? id, String? name}) {
    return Category(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

