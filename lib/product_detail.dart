import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:wedding_collection_new/db_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  FirebaseService firebaseService = FirebaseService();
  late Map<String, dynamic> _product;
  List<Map<String, String>> _bookedDates = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isAvailable = true;

  final TextEditingController _totalRentController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

void _loadProductDetails() async {
  try {
    Map<String, dynamic> product = await firebaseService.fetchProduct(widget.productId);

    // Log the raw fetched data to check for total_rent and advance
    print("Fetched product data: $product");

    setState(() {
      _product = product;

      _bookedDates = List<Map<String, String>>.from(
        (product['booked_dates'] as List<dynamic>?)?.map((date) {
          String startDate = (date['start_date'] ?? '').toString();
          String endDate = (date['end_date'] ?? '').toString();

          // Parse total_rent and advance as integers (defaulting to 0 if not present)
          String totalRent = (date['total_rent']??'0').toString();
             

          String advance = (date['advance']?? '0').toString();
           

          print("Start Date: $startDate, End Date: $endDate, Total Rent: $totalRent, Advance: $advance"); // Debug print

          return {
            'start_date': startDate,
            'end_date': endDate,
            'total_rent': totalRent.toString(),
            'advance': advance.toString(),
            'booking_id': (date['booking_id'] ?? '').toString(),
          };
        }).toList() ?? [],
      );
      _isLoading = false;
    });
  } catch (e) {
    print("Error loading product details: $e");
  }
}

  // Pick date range using the built-in date range picker
  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null && picked.start != picked.end) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _checkAvailability(_startDate!, _endDate!);
      });
    }
  }

  // Check if the selected date range overlaps with existing bookings
  void _checkAvailability(DateTime startDate, DateTime endDate) async {
    bool isAvailable = await firebaseService.checkAvailability(
      widget.productId,
      startDate,
      endDate,
    );

    setState(() {
      _isAvailable = isAvailable;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAvailable
              ? 'The selected date range is available!'
              : 'The selected date range is already booked!',
        ),
        backgroundColor: isAvailable ? Colors.green : Colors.red,
      ),
    );
  }

  // Show the bottom sheet for booking
  void _showBookingBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _totalRentController,
                decoration: const InputDecoration(
                  labelText: 'Total Rent',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _advanceController,
                decoration: const InputDecoration(
                  labelText: 'Advance',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _bookProduct();
                  Navigator.pop(
                      context); // Close the bottom sheet after booking
                },
                child: const Text('Book Product'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Book the product for the selected range of dates
  Future<void> _bookProduct() async {
    if (_startDate != null &&
        _endDate != null &&
        _isAvailable &&
        _totalRentController.text.isNotEmpty &&
        _advanceController.text.isNotEmpty) {
      double totalRent = double.tryParse(_totalRentController.text) ?? 0.0;
      double advance = double.tryParse(_advanceController.text) ?? 0.0;

      if (advance > totalRent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Advance cannot be greater than Total Rent!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Generate a unique booking ID (or you can use Firestore's auto-generated ID)
      String bookingId = DateTime.now().millisecondsSinceEpoch.toString();

      // Booking the product for the selected range
      await firebaseService.addBookingDates(
        widget.productId,
        _startDate!,
        _endDate!,
        totalRent,
        advance,
      );
      setState(() {
        _bookedDates.add({
          'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
          'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
          'total_rent': totalRent.toString(),
          'advance': advance.toString(),
          'booking_id': bookingId, // Add the booking ID for canceling later
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product booked for selected range of dates!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all details and check availability.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_product['name']),
      ),
      body: SingleChildScrollView(
        // Make the entire body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _product['images'].length,
                  itemBuilder: (context, index) {
                    String imageUrl =
                        _product['images'][index]; // Actual image URL
                    String defaultImageUrl =
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7xBNBjcKl82vxd9TSRFYTTUOJxRrJkwEN3Q&s'; // Default image URL
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => const Center(
                          child:
                              CircularProgressIndicator()), // Loading indicator
                      errorWidget: (context, url, error) => Image.network(
                          defaultImageUrl), // Default image in case of error
                      fit: BoxFit.cover, // Optional: Adjust image fit
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickDateRange,
                child: const Text('Pick Date Range'),
              ),
              const SizedBox(height: 16),
              if (_startDate != null && _endDate != null)
                Text(
                  'Selected Date Range: ${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isAvailable
                    ? _showBookingBottomSheet
                    : null, // Show BottomSheet if available
                child: const Text('Book Product'),
              ),
              const SizedBox(height: 16),
              const Text('Booked Dates:'),
              _bookedDates.isEmpty
                  ? const Text('No dates booked yet.')
                  : SingleChildScrollView(
                      // Make the table scrollable horizontally
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('From')),
                          DataColumn(label: Text('To')),
                          DataColumn(label: Text('Total')),
                          DataColumn(label: Text('Advance')),
                          DataColumn(label: Text('Cancel')),
                        ],
                        rows: _bookedDates.map((booked) {
                          return DataRow(cells: [
                            DataCell(Text(DateFormat('dd/MM/yy').format(
                                DateTime.parse(booked['start_date'] ?? '')))),
                            DataCell(Text(DateFormat('dd/MM/yy').format(
                                DateTime.parse(booked['end_date'] ?? '')))),
                            DataCell(Text(booked['total_rent'] ??
                                '0.00')), // Use 0.00 if null
                            DataCell(Text(booked['advance'] ??
                                '0.00')), // Use 0.00 if null
                            DataCell(IconButton(
                              icon: const Icon(Icons.cancel),
                              color: Colors.red,
                              onPressed: () => _cancelBooking(booked),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Cancel a specific booking
  Future<void> _cancelBooking(Map<String, String> booked) async {
    String bookingId = booked['booking_id']!;
    DateTime startDate = DateTime.parse(
        booked['start_date']!); // Parse the start date from the booking

    // Call the cancelBooking function from FirebaseService and pass the startDate
    try {
      await firebaseService.cancelBooking(widget.productId, startDate);

      // After successful cancellation, remove it from the local list
      setState(() {
        _bookedDates
            .remove(booked); // Remove the cancelled booking from the list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
