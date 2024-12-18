import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wedding_collection_new/db_helper.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart';

class BookProductScreen extends StatefulWidget {
  final String productId;
  final Booking? booking;
  final bool isEdit;

  const BookProductScreen(
      {super.key, required this.productId, this.booking, this.isEdit = false});

  @override
  _BookProductScreenState createState() => _BookProductScreenState();
}

class _BookProductScreenState extends State<BookProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _totalRentController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _dateRangeController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      final booking = widget.booking!;
      _customerNameController.text = booking.customerName;
      _contactController.text = booking.contact;
      _totalRentController.text = booking.totalRent.toString();
      _advanceController.text = booking.advance.toString();
      _startDate = booking.startDate;
      _endDate = booking.endDate;
      _dateRangeController.text =
          '${DateFormat('dd/MM/yy').format(_startDate!)} to ${DateFormat('dd/MM/yy').format(_endDate!)}';
      _isAvailable = true; // Assume the date range is available for editing
    }
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _dateRangeController.text =
            '${DateFormat('dd/MM/yy').format(_startDate!)} to ${DateFormat('dd/MM/yy').format(_endDate!)}';
      });

      // Check availability after date selection
      await _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final bool isAvailable = await _firebaseService.checkAvailability(
          widget.productId,
          _startDate!,
          _endDate!,
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _bookOrEditProduct() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_customerNameController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _totalRentController.text.isEmpty ||
        _advanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int totalRent = int.tryParse(_totalRentController.text) ?? 0;
    final int advance = int.tryParse(_advanceController.text) ?? 0;

    if (advance > totalRent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Advance cannot be greater than Total Rent!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Booking booking = Booking(
      startDate: _startDate!,
      endDate: _endDate!,
      totalRent: totalRent,
      advance: advance,
      customerName: _customerNameController.text,
      contact: _contactController.text,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      if (!widget.isEdit) {
        // New Booking
        await _firebaseService.addBookingDates(widget.productId, booking);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Edit Existing Booking
        await _firebaseService.updateBooking(widget.productId, booking);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context, booking);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'Book Product' : 'Edit Booking'),
      ),
      body: _isLoading
          ? Shimmer.fromColors(
              child: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                child: Card(),
              ),
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black12,
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : Colors.black26,
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickDateRange,
                      child: TextFormField(
                        enabled: false,
                        controller: _dateRangeController,
                        decoration: const InputDecoration(
                          labelText: 'Select Dates',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                          labelText: 'Contact',
                          border: OutlineInputBorder(),
                          counterText: ''),
                      keyboardType: TextInputType.name,
                      maxLength: 10,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _totalRentController,
                      decoration: const InputDecoration(
                        labelText: 'Total Rent',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _advanceController,
                      decoration: const InputDecoration(
                        labelText: 'Advance',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _bookOrEditProduct,
                      child:
                          Text(!widget.isEdit ? 'Book Now' : 'Update Booking'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
