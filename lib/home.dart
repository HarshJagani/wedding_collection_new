import 'package:flutter/material.dart';
import 'package:wedding_collection_new/db_helper.dart'; // FirebaseService file
import 'package:wedding_collection_new/product_detail.dart'; // Product details screen
import 'package:wedding_collection_new/upload_product.dart'; // Add Product screen
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String defaultImageUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7xBNBjcKl82vxd9TSRFYTTUOJxRrJkwEN3Q&s'; // Default image URL
  FirebaseService firebaseService = FirebaseService();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true; // Variable to track loading state

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Load products when the page is initialized
  }

  // Load products from Firestore
  void _loadProducts() async {
    try {
      List<Map<String, dynamic>> products =
          await firebaseService.fetchAllProducts();
      setState(() {
        _products = products;
        _isLoading = false; // Stop loading when data is fetched
      });
    } catch (e) {
      print("Error loading products: $e");
      setState(() {
        _isLoading = false; // Stop loading in case of an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : _products.isEmpty
              ? const Center(
                  child: Text(
                      'No Data Found')) // Show "No Data Found" text if the list is empty
              : RefreshIndicator(
                  color: Colors.orange.shade400,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    _loadProducts();
                  },
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product[
                                    'product_id'], // Pass productId to details screen
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CachedNetworkImage(
                            height: 50, width: 50,
                            imageUrl: product['images'][0],
                            placeholder: (context, url) => const Center(
                                child:
                                    CircularProgressIndicator()), // Loading indicator
                            errorWidget: (context, url, error) => Image.network(
                                defaultImageUrl), // Default image in case of error
                            fit: BoxFit.cover, // Optional: Adjust image fit
                          ),
                          title: Text(product['name']),
                          subtitle: const Text(
                              'Tap to view details'), // You can add more details here
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to Add Product screen and wait for result (pop back when done)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          // After adding the product, refresh the list
          _loadProducts();
        }, // Icon for the FloatingActionButton
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
