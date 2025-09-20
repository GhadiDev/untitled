import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/ui/check_out_screen.dart';
import '../viewmodels/home_provider.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'التصنيفات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,

          ),
        ),
        backgroundColor: Color.fromRGBO(242, 247, 253, 1),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(fontSize: 16, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Category horizontal scroll
              _buildCategoryList(provider),

              // Products grid
              Expanded(child: _buildProductsGrid(provider)),

              // Bottom cart summary
              _buildCartSummary(provider),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(HomeProvider provider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length, // +1 for "All" category
        itemBuilder: (context, index) {
          // if (index == 0) {
          //   // "All" category
          //   final isSelected = provider.selectedCategoryId == 0;
          //   return _buildCategoryChip(
          //     'All',
          //     isSelected,
          //     () => provider.selectCategory(0),
          //   );
          // }

          final category = provider.categories[index];
          final isSelected = provider.selectedCategoryId == category.id;

          return _buildCategoryChip(
            category.name,
            isSelected,
                () => provider.selectCategory(category.id!),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String name, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Color.fromRGBO(242, 247, 253, 1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, color: Colors.black, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                name,
                style: TextStyle(
                  fontFamily: "markazitext",
                  color: isSelected ? Colors.black : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(HomeProvider provider) {
    if (provider.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 3,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        return _buildProductCard(product, provider);
      },
    );
  }

  Widget _buildProductCard(Product product, HomeProvider provider) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child:
                product.image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  ),
                )
                    : _buildPlaceholderImage(),
              ),
            ),

            const SizedBox(height: 8),

            // Product name
            Text(
              product.name,

              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,

                color: const Color.fromARGB(195, 4, 70, 128),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Product price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${product.price.toStringAsFixed(2)} SR',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Quantity controls
                Expanded(child: _buildQuantityControls(product, provider)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildQuantityControls(Product product, HomeProvider provider) {
    return FutureBuilder<int>(
      future: provider.getProductCountInCart(product.id!),
      builder: (context, snapshot) {
        final quantity = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Color.fromRGBO(221, 235, 240, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus button
              GestureDetector(
                onTap:
                quantity > 0
                    ? () => _removeFromCart(product, provider)
                    : null,

                child: Icon(
                  Icons.remove,
                  color: Color.fromARGB(255, 51, 50, 148),
                  size: 20,
                ),
              ),

              // Quantity text
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              // Plus button
              GestureDetector(
                onTap: () => _addToCart(product, provider),
                child: const Icon(
                  Icons.add,
                  color: Color.fromARGB(255, 51, 50, 148),
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartSummary(HomeProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(86, 157, 209, 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // View Cart button
          GestureDetector(
            onTap: () {
              // TODO: Navigate to cart screen
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Cart screen coming soon!')),
              // );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (c) => CheckOutScreen(total: provider.totalCartPrice),
                ),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'عرض السلة',
                  style: TextStyle(
                    fontFamily: 'markazitext',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Total price
          Text(
            '${provider.totalCartPrice.toStringAsFixed(2)} SAR',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,

              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product, HomeProvider provider) {
    provider.addToCart(product.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(Product product, HomeProvider provider) {
    // Find the cart item to remove
    // final cartItem =
    //     provider.cartItems
    //         .where((item) => item.product.id == product.id)
    //         .firstOrNull;

    if (product != null) {
      provider.removeProductFromCart(product.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} removed from cart'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
