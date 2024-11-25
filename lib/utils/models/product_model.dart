import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // Firestore document ID
  final String name;
  final List<ImageData> images; // Updated to use ImageData
  final List<Booking> bookedDates;

  Product({
    required this.id,
    required this.name,
    required this.images,
    required this.bookedDates,
  });

  // Factory constructor to create a Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    List<ImageData> images = (data['images'] as List<dynamic>? ?? [])
        .map((e) => ImageData.fromMap(e as Map<String, dynamic>))
        .toList();

    List<Booking> bookings = (data['booked_dates'] as List<dynamic>? ?? [])
        .map((e) => Booking.fromMap(e as Map<String, dynamic>))
        .toList();

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      images: images,
      bookedDates: bookings,
    );
  }

  // Convert Product object to a Map for Firestore operations
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'images': images.map((image) => image.toMap()).toList(),
      'booked_dates': bookedDates.map((b) => b.toMap()).toList(),
    };
  }
}

class Booking {
  final DateTime startDate;
  final DateTime endDate;
  final int totalRent; // Changed to int
  final int advance; // Changed to int
  final String customerName; // New field
  final String contact; // New field

  Booking({
    required this.startDate,
    required this.endDate,
    required this.totalRent,
    required this.advance,
    required this.customerName,
    required this.contact,
  });

  // Factory constructor to create a Booking from Map data
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      startDate: (map['start_date'] as Timestamp).toDate(),
      endDate: (map['end_date'] as Timestamp).toDate(),
      totalRent: map['total_rent'] ?? 0,
      advance: map['advance'] ?? 0,
      customerName: map['customer_name'] ?? '-',
      contact: map['contact'] ?? '-',
    );
  }

  // Convert Booking object to a Map
  Map<String, dynamic> toMap() {
    return {
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'total_rent': totalRent,
      'advance': advance,
      'customer_name': customerName,
      'contact': contact,
    };
  }
}

class ImageData {
  final String imagePath; // Firebase Storage path
  final String imageUrl; // Public URL for the image

  ImageData({
    required this.imagePath,
    required this.imageUrl,
  });

  // Factory constructor to create an ImageData object from a Map
  factory ImageData.fromMap(Map<String, dynamic> map) {
    return ImageData(
      imagePath: map['image_path'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }

  // Convert ImageData object to a Map for Firestore operations
  Map<String, dynamic> toMap() {
    return {
      'image_path': imagePath,
      'image_url': imageUrl,
    };
  }
}
