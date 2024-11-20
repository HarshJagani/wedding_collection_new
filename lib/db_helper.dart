import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add new product to Firestore (without booking dates)
  Future<void> addProduct(String name, List<String> images) async {
    try {
      // Create product data map without booked_dates
      Map<String, dynamic> productData = {
        'name': name,
        'images': images,
        'booked_dates': [], // Start with an empty list for booked_dates
      };

      // Add product data to Firestore under the 'products' collection
      await _db.collection('products').add(productData);
      print("Product added successfully!");
    } catch (e) {
      print('Error adding product: $e');
    }
  }


// Cancel a specific booking for a product
Future<void> cancelBooking(String productId, DateTime startDate) async {
  try {
    // Fetch the product document from Firestore
    DocumentSnapshot productSnapshot =
        await _db.collection('products').doc(productId).get();

    if (productSnapshot.exists) {
      var productData = productSnapshot.data() as Map<String, dynamic>;

      // Fetch the list of booked dates
      List<dynamic> bookedDates = List.from(productData['booked_dates'] ?? []);
      
      // Find the booking entry that matches the start date
      var bookingToCancel = bookedDates.firstWhere(
        (booking) {
          Timestamp bookedStartTimestamp = booking['start_date'] as Timestamp;
          DateTime bookedStartDate = bookedStartTimestamp.toDate();
          return bookedStartDate.isAtSameMomentAs(startDate);
        },
        orElse: () => null,
      );

      // If the booking is found, remove it from the list
      if (bookingToCancel != null) {
        bookedDates.remove(bookingToCancel);

        // Update Firestore with the new list of booked dates
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


  Future<void> addBookingDates(
    String productId,
    DateTime startDate,
    DateTime endDate,
    double totalRent, // New parameter for total rent
    double advance, // New parameter for advance
  ) async {
    try {
      // Fetch the product document from Firestore
      DocumentSnapshot productSnapshot =
          await _db.collection('products').doc(productId).get();
      if (productSnapshot.exists) {
        var productData = productSnapshot.data() as Map<String, dynamic>;
        List<dynamic> bookedDates =
            List.from(productData['booked_dates'] ?? []);

        // Check if the new date range overlaps with any existing booked range
        for (var booked in bookedDates) {
          Timestamp bookedStartTimestamp = booked['start_date'] as Timestamp;
          Timestamp bookedEndTimestamp = booked['end_date'] as Timestamp;

          DateTime bookedStartDate = bookedStartTimestamp.toDate();
          DateTime bookedEndDate = bookedEndTimestamp.toDate();

          if ((startDate.isBefore(bookedEndDate) &&
              endDate.isAfter(bookedStartDate))) {
            print("This date range is already booked!");
            return; // Do not proceed if there is an overlap
          }
        }

        // Add the new booking data
        bookedDates.add({
          'start_date': Timestamp.fromDate(startDate),
          'end_date': Timestamp.fromDate(endDate),
          'total_rent': totalRent,
          'advance': advance,
        });

        // Update Firestore with the new booking ranges
        await _db.collection('products').doc(productId).update({
          'booked_dates': bookedDates,
        });

        print("Booking dates added successfully with rent and advance!");
      } else {
        print("Product not found.");
      }
    } catch (e) {
      print('Error adding booking dates: $e');
    }
  }

  // Fetch all products from Firestore
  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    try {
      QuerySnapshot snapshot = await _db.collection('products').get();

      List<Map<String, dynamic>> productsList = [];

      for (var doc in snapshot.docs) {
        // Convert each document to a map
        Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;

        // Add the product ID to the data (Firestore document ID)
        productData['product_id'] = doc.id;

        // Add the product data to the list
        productsList.add(productData);
      }

      return productsList;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Fetch product data by product ID, including booked dates as date ranges
  Future<Map<String, dynamic>> fetchProduct(String productId) async {
    try {
      // Fetch product document from Firestore
      DocumentSnapshot productSnapshot =
          await _db.collection('products').doc(productId).get();
      if (productSnapshot.exists) {
        var productData = productSnapshot.data() as Map<String, dynamic>;

        // Safely convert booked_dates to a list of date ranges
        List<Map<String, String>> bookedDates = [];
        if (productData['booked_dates'] != null) {
          bookedDates = (productData['booked_dates'] as List<dynamic>).map((e) {
            Timestamp startTimestamp = e['start_date'];
            Timestamp endTimestamp = e['end_date'];

            return {
              'start_date': startTimestamp.toDate().toIso8601String(),
              'end_date': endTimestamp.toDate().toIso8601String(),
            };
          }).toList();
        }

        // Return the product data as a Map
        return {
          'name': productData['name'],
          'images': List<String>.from(productData['images']),
          'booked_dates': bookedDates,
        };
      } else {
        print("Product not found.");
        return Future.error('Product not found');
      }
    } catch (e) {
      print('Error fetching product: $e');
      return Future.error(e);
    }
  }

  // Check if a specific date range is available for booking
  Future<bool> checkAvailability(
      String productId, DateTime startDate, DateTime endDate) async {
    try {
      // Fetch the product data by ID
      final product = await fetchProduct(productId);
      List<Map<String, String>> bookedDates = product['booked_dates'];

      // Check if the new date range conflicts with any existing booked range
      for (var booked in bookedDates) {
        DateTime bookedStartDate = DateTime.parse(booked['start_date']!);
        DateTime bookedEndDate = DateTime.parse(booked['end_date']!);

        // Conflict occurs if:
        // New start date is before or at an existing end date AND
        // New end date is after or at an existing start date
        if (!(endDate.isBefore(bookedStartDate) ||
            startDate.isAfter(bookedEndDate))) {
          return false; // Conflict found
        }
      }

      return true; // No conflicts
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  // Helper method to get all dates in a given range (inclusive)
  List<DateTime> _getDatesInRange(DateTime startDate, DateTime endDate) {
    List<DateTime> datesInRange = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      datesInRange.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return datesInRange;
  }
}
