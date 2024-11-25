// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wedding_collection_new/db_helper.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _addProduct() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a product name.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Show a progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Uploading Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please wait',style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );  

    try {
      // Create a Product object
      final Product product = Product(
          name: name,
          images: [], // URLs will be updated after upload
          bookedDates: [],
          id: '');

      // Upload images and save product
      await _firebaseService.addProductWithProgress(
        product,
        _selectedImages,
      );

      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Close the screen
    } catch (e) {
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Images Grid View
              Text("Product Images"),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedImages.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  if (index < _selectedImages.length) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImages[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : Colors.black12,
                        ),
                        child: Center(
                          child: Icon(Icons.add_a_photo, size: 40),
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          // Submit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
            onPressed: _addProduct,
            child: Text('Add Product'),
                    ),
                  ),
          ),
    );
  }
}
