import 'package:flutter/material.dart';
import '../data/sqlite_data_source.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/cart_item_with_product.dart';

class HomeProvider with ChangeNotifier {

  //Connect to SQLite database
  final SqliteDataSource _dataSource = SqliteDataSource();

  // State variables
  List<Category> _categories = [];
  List<Product> _products = [];
  List<CartItemWithProduct> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  int _selectedCategoryId = 1; // 0 means all categories
  double _totalCartPrice = 0.0;
  int _totalCartItems = 0;

  // Getters
  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<CartItemWithProduct> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedCategoryId => _selectedCategoryId;
  double get totalCartPrice => _totalCartPrice;
  int get totalCartItems => _totalCartItems;

  // Initialize the app - check if first time running
  Future<void> init() async {
    _setLoading(true);
    try {
      // Check if this is the first time running the app
      final existingCategories = await _dataSource.getAllCategories();

      if (existingCategories.isEmpty) {
        // First time running - add sample data
        await _addSampleData();
      }

      // Load all data
      await _loadCategories();
      await _loadProducts();
      await _loadCartItems();

      _setError(null);
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add sample data for first time users
  Future<void> _addSampleData() async {
    // Add sample categories
    await _dataSource.insertCategory('أفضل العروض');
    await _dataSource.insertCategory('مستورد');
    await _dataSource.insertCategory('أجبان قابلة للدهن');
    await _dataSource.insertCategory('أجبان');

    await _dataSource.insertProduct(
      name: 'Double Cheeseburger',
      price: 32.99,
      image: 'assets/images/1.png',
      categoryId: 1,
    );
    await _dataSource.insertProduct(
      name: 'Chicken Burger',
      price: 29.99,
      image: 'assets/images/2.png',
      categoryId: 1,
    );
    await _dataSource.insertProduct(
      name: 'Hamburger',
      price: 26.39,
      image: 'assets/images/3.png',
      categoryId: 1,
    );

    await _dataSource.insertProduct(
      name: 'Double King Chicken Tasty',
      price: 350.00,
      image: 'assets/images/4.png',
      categoryId: 2,
    );
    await _dataSource.insertProduct(
      name: 'Chicken burger',
      price: 29.57,
      image: 'assets/images/5.png',
      categoryId: 2,
    );


    await _dataSource.insertProduct(
      name: ' King Chicken Tasty',
      price: 29.57,
      image: 'assets/images/6.png',
      categoryId: 2,
    );

  }

  // Load categories from database
  Future<void> _loadCategories() async {
    try {
      final categoryMaps = await _dataSource.getAllCategories();
      _categories = categoryMaps.map((map) => Category.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  // Load products from database
  Future<void> _loadProducts() async {
    try {
      List<Map<String, dynamic>> productMaps;

      if (_selectedCategoryId == 0) {
        // Load all products
        productMaps = await _dataSource.getAllProducts();
      } else {
        // Load products by category
        productMaps = await _dataSource.getProductsByCategory(
          _selectedCategoryId,
        );
      }

      _products = productMaps.map((map) => Product.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: $e');
    }
  }

  // Load cart items from database
  Future<void> _loadCartItems() async {
    try {
      final cartItemMaps = await _dataSource.getCartItems();
      _cartItems =
          cartItemMaps.map((map) => CartItemWithProduct.fromMap(map)).toList();

      // Update cart totals
      _totalCartPrice = await _dataSource.getTotalPriceInCart();
      _totalCartItems = await _dataSource.getCartItemCount();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load cart items: $e');
    }
  }

  // Category methods
  Future<void> insertCategory(String name) async {
    try {
      await _dataSource.insertCategory(name);
      await _loadCategories();
    } catch (e) {
      _setError('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      await _dataSource.updateCategory(id, name);
      await _loadCategories();
    } catch (e) {
      _setError('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dataSource.deleteCategory(id);
      await _loadCategories();
      // If deleted category was selected, show all products
      if (_selectedCategoryId == id) {
        await selectCategory(0);
      }
    } catch (e) {
      _setError('Failed to delete category: $e');
    }
  }

  // Product methods
  Future<void> insertProduct({
    required String name,
    required double price,
    String? image,
    required int categoryId,
  }) async {
    try {
      await _dataSource.insertProduct(
        name: name,
        price: price,
        image: image,
        categoryId: categoryId,
      );
      await _loadProducts();
    } catch (e) {
      _setError('Failed to add product: $e');
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required double price,
    String? image,
    required int categoryId,
  }) async {
    try {
      await _dataSource.updateProduct(
        id: id,
        name: name,
        price: price,
        image: image,
        categoryId: categoryId,
      );
      await _loadProducts();
    } catch (e) {
      _setError('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dataSource.deleteProduct(id);
      await _loadProducts();
    } catch (e) {
      _setError('Failed to delete product: $e');
    }
  }

  // Cart methods
  Future<void> addToCart(int productId) async {
    try {
      await _dataSource.addToCart(productId);
      await _loadCartItems();
    } catch (e) {
      _setError('Failed to add product to cart: $e');
    }
  }

  Future<void> removeFromCart(int cartId) async {
    try {
      await _dataSource.removeFromCart(cartId);
      await _loadCartItems();
    } catch (e) {
      _setError('Failed to remove product from cart: $e');
    }
  }

  Future<void> removeProductFromCart(int productId) async {
    try {
      await _dataSource.removeProductFromCart(productId);
      await _loadCartItems();
    } catch (e) {
      _setError('Failed to remove product from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _dataSource.clearCart();
      await _loadCartItems();
    } catch (e) {
      _setError('Failed to clear cart: $e');
    }
  }

  Future<bool> isProductInCart(int productId) async {
    try {
      return await _dataSource.isProductInCart(productId);
    } catch (e) {
      _setError('Failed to check cart status: $e');
      return false;
    }
  }

  Future<int> getProductCountInCart(int productId) async {
    try {
      return await _dataSource.getProductCountInCart(productId);
    } catch (e) {
      _setError('Failed to get product count: $e');
      return 0;
    }
  }

  // UI methods
  Future<void> selectCategory(int categoryId) async {
    _selectedCategoryId = categoryId;
    await _loadProducts();
  }

  Future<void> refreshData() async {
    await _loadCategories();
    await _loadProducts();
    await _loadCartItems();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // Get products by category name
  List<Product> getProductsByCategoryName(String categoryName) {
    final category = _categories.firstWhere(
          (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => Category(id: -1, name: ''),
    );

    if (category.id == -1) return [];

    return _products
        .where((product) => product.categoryId == category.id)
        .toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products
        .where(
          (product) => product.name.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();
  }

  @override
  void dispose() {
    _dataSource.close();
    super.dispose();
  }
}
