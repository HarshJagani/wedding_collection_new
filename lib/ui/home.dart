// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wedding_collection_new/db_helper.dart'; // FirebaseService file
import 'package:wedding_collection_new/ui/product_detail.dart'; // Product details screen
import 'package:wedding_collection_new/ui/upload_product.dart'; // Add Product screen
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wedding_collection_new/utils/widgets/helper/helper_methods.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart';
import 'package:wedding_collection_new/utils/widgets/no_internet_widget.dart';
import 'package:wedding_collection_new/utils/widgets/shimmer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String defaultImageUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7xBNBjcKl82vxd9TSRFYTTUOJxRrJkwEN3Q&s'; // Default image URL
  FirebaseService firebaseService = FirebaseService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true; // Variable to track loading state
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Load products when the page is initialized
  }

  // Load products from Firestore
  void _loadProducts() async {
    try {
      List<Product> products = await firebaseService.fetchAllProducts();
      setState(() {
        _products = products;
        _filteredProducts = products; // Initially, all products are visible
        _isLoading = false; // Stop loading when data is fetched
      });
    } catch (e) {
      print("Error loading products: $e");
      setState(() {
        _isLoading = false; // Stop loading in case of an error
      });
    }
  }

  // Function to delete the product
  void _deleteProduct(String productId,
      {required List<ImageData> images}) async {
    try {
      _isLoading = true;
      await firebaseService.deleteProduct(
          productId, images); // Delete from Firebase
      setState(() {
        _products.removeWhere(
            (product) => product.id == productId); // Remove from local list
        _filteredProducts = _products; // Update filtered list
      });
      print("Product deleted successfully");
      Navigator.pop(context);
      _isLoading = false;
    } catch (e) {
      print("Error deleting product: $e");
      Navigator.pop(context);
      _isLoading = false;
    }
  }

  // Search functionality
  void _searchProducts(String query) {
    final DateTime? enteredDate =
        _tryParseDate(query); // Check if the query is a valid date

    setState(() {
      _filteredProducts = _products.where((product) {
        // Check if name matches
        final matchesName =
            product.name.toLowerCase().contains(query.toLowerCase());

        // Check if the entered date matches start, end, or is within the range
        final matchesDate = enteredDate != null &&
            product.bookedDates.any((booking) =>
                enteredDate
                    .isAtSameMomentAs(booking.startDate) || // Match startDate
                enteredDate
                    .isAtSameMomentAs(booking.endDate) || // Match endDate
                (enteredDate.isAfter(booking.startDate) && // Falls within range
                    enteredDate.isBefore(booking.endDate)));

        return matchesName || matchesDate;
      }).toList();
    });
  }

  // Helper function to parse date
  DateTime? _tryParseDate(String input) {
    try {
      return DateFormat('dd/MM/yy')
          .parseStrict(input); // Adjust format if needed
    } catch (e) {
      return null; // Return null if the input is not a valid date
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or date (dd/MM/yy)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _searchProducts, // Call search method on text change
            ),
          ),
          Expanded(
            child: _isLoading
                ? ShimmerLoadingWidget() // Show loading indicator
                : _filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                            'No Data Found')) // Show "No Data Found" text if the list is empty
                    : RefreshIndicator(
                        color: Color(0xFF4B68FF),
                        backgroundColor: Colors.white,
                        onRefresh: () async {
                          _loadProducts();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GridView.builder(
                            shrinkWrap: true,
                            addAutomaticKeepAlives: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        productId: product
                                            .id, // Pass productId to details screen
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  HelperMethods().showaAlertDialog(context,
                                      onPressed: () {
                                    _deleteProduct(product.id,
                                        images: product.images);
                                  },
                                      title: 'Delete',
                                      subTitle:
                                          'Are you sure you want to delete this product?');
                                },
                                child: Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                        child: CachedNetworkImage(
                                          height: 200,
                                          width: double.maxFinite,
                                          imageUrl:
                                              product.images.first.imageUrl,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                            child: Card(),
                                            baseColor:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white10
                                                    : Colors.black12,
                                            highlightColor:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white12
                                                    : Colors.black26,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.network(
                                                  defaultImageUrl), // Default image in case of error
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '#${product.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
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
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    ));
  }
}
