import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add new product to Firestore (without booking dates)
  Future<void> addProduct(Product product) async {
    try {
      await _db.collection('products').add(product.toMap());
      print("Product added successfully!");
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<List<ImageData>> uploadImages(List<File> images) async {
    List<ImageData> uploadedImages = [];
    for (File image in images) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = _storage.ref().child('products/$fileName');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedImages.add(
          ImageData(imagePath: ref.fullPath, imageUrl: downloadUrl),
        );
      } catch (e) {
        print('Error uploading image: $e');
        rethrow;
      }
    }
    return uploadedImages;
  }

  // Cancel a specific booking for a product
  Future<void> cancelBooking(String productId, DateTime startDate) async {
    try {
      DocumentSnapshot productSnapshot =
          await _db.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        var productData = productSnapshot.data() as Map<String, dynamic>;
        List<dynamic> bookedDates =
            List.from(productData['booked_dates'] ?? []);

        var bookingToCancel = bookedDates.firstWhere(
          (booking) {
            Timestamp bookedStartTimestamp = booking['start_date'] as Timestamp;
            return bookedStartTimestamp.toDate().isAtSameMomentAs(startDate);
          },
          orElse: () => null,
        );

        if (bookingToCancel != null) {
          bookedDates.remove(bookingToCancel);

          await _db.collection('products').doc(productId).update({
            'booked_dates': bookedDates,
          });

          print("Booking cancelled successfully!");
        } else {
          print("Booking not found for the selected date.");
        }
      } else {
        print("Product not found.");
      }
    } catch (e) {
      print('Error canceling booking: $e');
    }
  }

  Future<void> updateBooking(String productId, Booking updatedBooking) async {
    try {
      // Fetch the product document from Firestore
      DocumentSnapshot productSnapshot =
          await _db.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        var productData = productSnapshot.data() as Map<String, dynamic>;
        List<dynamic> bookedDates =
            List.from(productData['booked_dates'] ?? []);

        // Find the existing booking to update by matching the start date
        var bookingToUpdate = bookedDates.firstWhere(
          (booking) {
            Timestamp bookedStartTimestamp = booking['start_date'] as Timestamp;
            return bookedStartTimestamp
                .toDate()
                .isAtSameMomentAs(updatedBooking.startDate);
          },
          orElse: () => null,
        );

        if (bookingToUpdate != null) {
          // Update the booking details (e.g., startDate, endDate, customerName)
          int index = bookedDates.indexOf(bookingToUpdate);

          // Update the relevant fields
          bookedDates[index] = updatedBooking
              .toMap(); // Assuming your Booking class has a toMap() method

          // Update the product with the new booking data
          await _db.collection('products').doc(productId).update({
            'booked_dates': bookedDates,
          });

          print("Booking updated successfully!");
        } else {
          print("Booking not found for the selected date.");
        }
      } else {
        print("Product not found.");
      }
    } catch (e) {
      print('Error updating booking: $e');
    }
  }

  Future<void> deleteProduct(String productId, List<ImageData> images) async {
    try {
      // Delete images from Firebase Storage
      for (var image in images) {
        await _storage.ref(image.imagePath).delete();
      }

      // Delete the product document from Firestore
      await _db.collection('products').doc(productId).delete();

      print("Product and its images deleted successfully!");
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Add booking dates for a product
  Future<void> addBookingDates(
    String productId,
    Booking
        booking, // Accepting the Booking object instead of individual fields
  ) async {
    try {
      // Fetch the product document from Firestore
      DocumentSnapshot productSnapshot =
          await _db.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        // Convert the document data to a Product model
        Product product = Product.fromFirestore(productSnapshot);

        // Check if the new date range overlaps with any existing booked range
        for (var booked in product.bookedDates) {
          if (!(booking.endDate.isBefore(booked.startDate) ||
              booking.startDate.isAfter(booked.endDate))) {
            print("This date range is already booked!");
            return; // If there's an overlap, do not proceed
          }
        }

        // Add the new booking to the bookedDates list
        List<Booking> updatedBookedDates = List.from(product.bookedDates)
          ..add(booking);

        // Update Firestore with the new booked dates
        await _db.collection('products').doc(productId).update({
          'booked_dates': updatedBookedDates.map((b) => b.toMap()).toList(),
        });

        print("Booking dates added successfully with customer details!");
      } else {
        print("Product not found.");
      }
    } catch (e) {
      print('Error adding booking dates: $e');
    }
  }

  // Fetch all products from Firestore
  Future<List<Product>> fetchAllProducts() async {
    try {
      QuerySnapshot snapshot = await _db.collection('products').get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Fetch a single product by ID, including booked dates
  Future<Product> fetchProduct(String productId) async {
    try {
      // Fetch product document from Firestore
      DocumentSnapshot productSnapshot =
          await _db.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        // Use the Product factory to create a Product object from Firestore data
        Product product = Product.fromFirestore(productSnapshot);

        return product; // Return the Product object
      } else {
        print("Product not found.");
        throw Exception("Product not found");
      }
    } catch (e) {
      print('Error fetching product: $e');
      throw e;
    }
  }

  Future<bool> checkAvailability(
      String productId, DateTime startDate, DateTime endDate) async {
    try {
      // Fetch the product using the updated fetchProduct function
      Product product = await fetchProduct(productId);

      // Loop through the booked dates for the product
      for (var booking in product.bookedDates) {
        // Compare the requested date range with existing bookings
        if (!(endDate.isBefore(booking.startDate) ||
            startDate.isAfter(booking.endDate))) {
          return false; // The date range is not available
        }
      }

      return true; // The date range is available
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }
}
