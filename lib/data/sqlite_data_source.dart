import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteDataSource {
  static Database? _database;
  static const String _databaseName = 'shopping_cart.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _tableCategory = 'Category';
  static const String _tableProduct = 'Products';
  static const String _tableCart = 'Cart';

  // Category table columns
  static const String _categoryId = 'ID';
  static const String _categoryName = 'Name';

  // Product table columns
  static const String _productId = 'ID';
  static const String _productName = 'name';
  static const String _productPrice = 'price';
  static const String _productImage = 'image';
  static const String _productCategoryId = 'categoryId';

  // Cart table columns
  static const String _cartId = 'ID';
  static const String _cartProductId = 'product_id';

  // Singleton pattern
  static final SqliteDataSource _instance = SqliteDataSource._internal();
  factory SqliteDataSource() => _instance;
  SqliteDataSource._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Category table
    await db.execute('''
      CREATE TABLE $_tableCategory (
        $_categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_categoryName TEXT NOT NULL
      )
    ''');

    // Create Products table
    await db.execute('''
      CREATE TABLE $_tableProduct (
        $_productId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_productName TEXT NOT NULL,
        $_productPrice REAL NOT NULL,
        $_productImage TEXT,
        $_productCategoryId INTEGER NOT NULL,
        FOREIGN KEY ($_productCategoryId) REFERENCES $_tableCategory ($_categoryId)
      )
    ''');

    // Create Cart table
    await db.execute('''
      CREATE TABLE $_tableCart (
        $_cartId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_cartProductId INTEGER NOT NULL,
        FOREIGN KEY ($_cartProductId) REFERENCES $_tableProduct ($_productId)
      )
    ''');
  }

  // Category CRUD operations
  Future<int> insertCategory(String name) async {
    final db = await database;
    return await db.insert(_tableCategory, {
      _categoryName: name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query(_tableCategory, orderBy: _categoryId);
  }

  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableCategory,
      where: '$_categoryId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateCategory(int id, String name) async {
    final db = await database;
    return await db.update(
      _tableCategory,
      {_categoryName: name},
      where: '$_categoryId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      _tableCategory,
      where: '$_categoryId = ?',
      whereArgs: [id],
    );
  }

  // Product CRUD operations
  Future<int> insertProduct({
    required String name,
    required double price,
    String? image,
    required int categoryId,
  }) async {
    final db = await database;
    return await db.insert(_tableProduct, {
      _productName: name,
      _productPrice: price,
      _productImage: image,
      _productCategoryId: categoryId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query(_tableProduct, orderBy: _productName);
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(
      int categoryId,
      ) async {
    final db = await database;
    return await db.query(
      _tableProduct,
      where: '$_productCategoryId = ?',
      whereArgs: [categoryId],
      orderBy: _productName,
    );
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableProduct,
      where: '$_productId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProduct({
    required int id,
    required String name,
    required double price,
    String? image,
    required int categoryId,
  }) async {
    final db = await database;
    return await db.update(
      _tableProduct,
      {
        _productName: name,
        _productPrice: price,
        _productImage: image,
        _productCategoryId: categoryId,
      },
      where: '$_productId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      _tableProduct,
      where: '$_productId = ?',
      whereArgs: [id],
    );
  }

  // Cart CRUD operations
  Future<int> addToCart(int productId) async {
    final db = await database;
    return await db.insert(_tableCart, {
      _cartProductId: productId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.$_cartId, p.$_productId, p.$_productName, p.$_productPrice, p.$_productImage, p.$_productCategoryId
      FROM $_tableCart c
      INNER JOIN $_tableProduct p ON c.$_cartProductId = p.$_productId
      ORDER BY c.$_cartId
    ''');
  }

  Future<int> removeFromCart(int cartId) async {
    final db = await database;
    return await db.delete(
      _tableCart,
      where: '$_cartId = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeProductFromCart(int productId) async {
    final db = await database;
    // String qury =
    //     "delete from $_tableCart where $_cartProductId = $productId LIMIT 1";

    // print(qury);
    // return db.rawDelete(qury);

    String query = '''
    DELETE FROM $_tableCart
    WHERE $_cartId = (
      SELECT $_cartId FROM $_tableCart
      WHERE $_cartProductId = ?
      ORDER BY $_cartId ASC
      LIMIT 1
    )
  ''';

    return db.rawDelete(query, [productId]);
  }

  Future<int> clearCart() async {
    final db = await database;
    return await db.delete(_tableCart);
  }

  Future<int> getCartItemCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableCart',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Check if product is in cart
  Future<bool> isProductInCart(int productId) async {
    final db = await database;
    final result = await db.query(
      _tableCart,
      where: '$_cartProductId = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }

  // Get total price for all products in cart
  Future<double> getTotalPriceInCart() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(p.$_productPrice) as total
      FROM $_tableCart c
      INNER JOIN $_tableProduct p ON c.$_cartProductId = p.$_productId
    ''');
    return (result.first['total'] as double?) ?? 0.0;
  }

  // Get count of specific product in cart by product ID
  Future<int> getProductCountInCart(int productId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableCart WHERE $_cartProductId = ?',
      [productId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
