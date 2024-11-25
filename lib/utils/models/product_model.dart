import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // Firestore document ID
  final String name;
  List<String> images;
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
    List<Booking> bookings = (data['booked_dates'] as List<dynamic>?)
            ?.map((e) => Booking.fromMap(e))
            .toList() ??
        [];
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      bookedDates: bookings,
    );
  }

  // Convert Product object to a Map for Firestore operations
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'images': images,
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
