import 'package:flutter/material.dart';
import 'package:wedding_collection_new/db_helper.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  FirebaseService firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _imagesController = TextEditingController();



  // Add new product to Firebase
  void _addProduct() async {
    String name = _nameController.text.trim();
    List<String> images = _imagesController.text.trim().split(',');

    if (name.isEmpty || images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid product information')),
      );
      return;
    }

    await firebaseService.addProduct(name, images);
    Navigator.pop(context);
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully!')),
    );

    // Clear fields after adding
    _nameController.clear();
    _imagesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imagesController,
              decoration: const InputDecoration(
                labelText: 'Images (comma-separated URLs)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
