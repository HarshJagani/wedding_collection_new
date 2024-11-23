// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:wedding_collection_new/db_helper.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart';

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

    if (name.isEmpty ||
        images.isEmpty ||
        images.any((image) => image.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid product information')),
      );
      return;
    }

    // Create a Product instance
    Product newProduct = Product(
      name: name,
      images: images.map((image) => image.trim()).toList(),
      bookedDates: [], id: '', // No bookings initially
    );

    // Add product using FirebaseService
    try {
      await firebaseService.addProduct(newProduct);

      // Navigate back and show success message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      // Clear input fields
      _nameController.clear();
      _imagesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
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
