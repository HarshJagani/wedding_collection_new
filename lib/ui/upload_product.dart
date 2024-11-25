import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wedding_collection_new/db_helper.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart'; // FirebaseService file

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final List<File> _selectedImages = [];
  final List<ImageData> _uploadedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  /// Pick images from the gallery
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  /// Upload images with progress tracking
  Future<List<ImageData>> _uploadImagesWithProgress(List<File> images) async {
    List<ImageData> uploadedImages = [];
    for (int i = 0; i < images.length; i++) {
      // Update progress for each file
      await firebaseService.uploadImages(images);
    }
    return uploadedImages;
  }

  /// Add the product with images to Firestore
  Future<void> _addProduct() async {
    String name = _nameController.text.trim();

    if (name.isEmpty || (_selectedImages.isEmpty && _uploadedImages.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide product name and images')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Show progress dialog
    _showProgressDialog();

    try {
      // Upload new images with progress tracking
      List<ImageData> uploadedNewImages = [];
      if (_selectedImages.isNotEmpty) {
        uploadedNewImages = await _uploadImagesWithProgress(_selectedImages);
      }

      // Combine new and previously uploaded images
      List<ImageData> allImages = [..._uploadedImages, ...uploadedNewImages];

      // Create product instance
      Product newProduct = Product(
        name: name,
        images: allImages,
        bookedDates: [],
        id: '', // Firestore will generate the ID
      );

      // Save product to Firestore
      await firebaseService.addProduct(newProduct);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
      Navigator.pop(context);

      // Clear inputs
      _nameController.clear();
      setState(() {
        _selectedImages.clear();
        _uploadedImages.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      // Close progress dialog and reset state
      Navigator.pop(context); // Close the dialog
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Uploading...'),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 16),
              Text('${(_uploadProgress * 100).toStringAsFixed(0)}% completed'),
            ],
          ),
        );
      },
    );
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
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Pick Images'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedImages.isEmpty && _uploadedImages.isEmpty
                  ? const Center(child: Text('No images selected'))
                  : GridView.builder(
                      itemCount:
                          _selectedImages.length + _uploadedImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of images per row
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        // Render uploaded images
                        if (index < _uploadedImages.length) {
                          final imageData = _uploadedImages[index];
                          return Stack(
                            children: [
                              Image.network(
                                imageData.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _uploadedImages.removeAt(index);
                                    });
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 12,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // Render new images to be uploaded
                        final localImageIndex = index - _uploadedImages.length;
                        return Stack(
                          children: [
                            Image.file(
                              _selectedImages[localImageIndex],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(localImageIndex);
                                  });
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 12,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            _isUploading
                ? Column(
                    children: [
                      const Text('Uploading...'),
                      LinearProgressIndicator(value: _uploadProgress),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _addProduct,
                    child: const Text('Add Product'),
                  ),
          ],
        ),
      ),
    );
  }
}
