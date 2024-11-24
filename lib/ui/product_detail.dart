import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wedding_collection_new/ui/book_product_screen.dart';
import 'package:wedding_collection_new/db_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wedding_collection_new/utils/widgets/helper/helper_methods.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_collection_new/utils/widgets/booking_detail_card.dart';
import 'package:wedding_collection_new/utils/widgets/no_booking_widget.dart';
import 'package:wedding_collection_new/utils/widgets/no_internet_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  FirebaseService firebaseService = FirebaseService();
  late Product _product;
  List<Booking> _bookedDates = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  void _loadProductDetails() async {
    try {
      Product product = await firebaseService.fetchProduct(widget.productId);
      setState(() {
        _product = product;
        _bookedDates =
            product.bookedDates; // Directly assign the list of bookings
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

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: _isLoading
          ? Scaffold(
              appBar: AppBar(
                title: const Text('Product Details'),
              ),
              body: Shimmer.fromColors(
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
              ),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text('Product Details'),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickDateRange,
                        child: const Text('Check Avaibility'),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookProductScreen(
                                    productId: widget.productId),
                              ));
                          _loadProductDetails();
                        }, // Show BottomSheet if available
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                // Make the entire body scrollable
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _product.images.length,
                        itemBuilder: (context, index) {
                          String imageUrl = Helprtmethods()
                              .convertGoogleDriveLink(
                                  _product.images[index]); // Actual image URL
                          String defaultImageUrl =
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7xBNBjcKl82vxd9TSRFYTTUOJxRrJkwEN3Q&s'; // Default image URL
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) => Shimmer.fromColors(
                              child: Container(),
                              baseColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white10
                                  : Colors.black12,
                              highlightColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white12
                                  : Colors.black26,
                            ), // Loading indicator
                            errorWidget: (context, url, error) => Image.network(
                                defaultImageUrl), // Default image in case of error
                            fit: BoxFit.cover, // Optional: Adjust image fit
                          );
                        },
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // if (_startDate != null && _endDate != null)
                    //   Text(
                    //     'Selected Date Range: ${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                    //     style: const TextStyle(fontSize: 16),
                    //   ),
                    const SizedBox(height: 16),
                    Text('Bookings :',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    _bookedDates.isEmpty
                        ? NoBookingWidget()
                        : BookingDetailsCard(
                            booking: _bookedDates, onCancel: _cancelBooking,productId: widget.productId,)
                  ],
                ),
              ),
            ),
    );
  }

  // Cancel a specific booking
  Future<void> _cancelBooking(Booking booking) async {
    try {
      _isLoading = true;
      Navigator.pop(context);
      // Call the cancelBooking function from FirebaseService and pass the startDate
      await firebaseService.cancelBooking(widget.productId, booking.startDate);

      // After successful cancellation, remove it from the local list
      setState(() {
        _bookedDates.remove(booking);
        // Remove the cancelled booking from the list
      });
      _isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _isLoading = false;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void launchApp(String? number) async {
    if (number != null && number != '-') {
      await canLaunchUrl(Uri(scheme: 'tel', path: '123'));
    } else {
      print('Could not launch $number');
    }
  }
}
