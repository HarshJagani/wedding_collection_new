import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_collection_new/ui/book_product_screen.dart';
import 'package:wedding_collection_new/utils/widgets/helper/helper_methods.dart';
import 'package:wedding_collection_new/utils/models/product_model.dart';
import 'package:wedding_collection_new/utils/widgets/booking_detail_row.dart';

class BookingDetailsCard extends StatelessWidget {
  final List<Booking> booking;
  final Future<void> Function(Booking)? onCancel;
  final String productId;
  const BookingDetailsCard(
      {super.key,
      required this.booking,
      required this.onCancel,
      required this.productId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingDetailRow(
                        keytext: 'From',
                        valuetext:
                            '${DateFormat('dd/MM/yyyy').format(booking[index].startDate)}',
                      ),
                      BookingDetailRow(
                        keytext: 'To',
                        valuetext:
                            '${DateFormat('dd/MM/yyyy').format(booking[index].endDate)}',
                      ),
                      BookingDetailRow(
                        keytext: 'Customer',
                        valuetext: '${booking[index].customerName}',
                      ),
                      GestureDetector(
                        onTap: () {
                          final uri =
                              Uri(scheme: 'tel', path: booking[index].contact);
                          launchUrl(uri);
                        },
                        child: BookingDetailRow(
                          keytext: 'Contanct',
                          valuetext: '${booking[index].contact}',
                        ),
                      ),
                      BookingDetailRow(
                        keytext: 'Total Rent',
                        valuetext: '${booking[index].totalRent}',
                      ),
                      BookingDetailRow(
                        keytext: 'Advance',
                        valuetext: '${booking[index].advance}',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Helprtmethods().showaAlertDialog(context,
                                    onPressed: onCancel != null
                                        ? () => onCancel!(booking[index])
                                        : null,
                                    tital: 'Cancel',
                                    subtital:
                                        'Are you sure you want to cancel this booking?');
                              },
                              child: Text('Cancel Booking',
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final updatedBooking = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookProductScreen(
                                      productId: productId,
                                      isEdit: true,
                                      booking: booking[index],
                                    ),
                                  ),
                                );

                                // If a booking is returned, update the list
                                if (updatedBooking != null) {
                                  booking[index] = updatedBooking;
                                  // Trigger a UI rebuild by calling setState
                                  (context as Element).markNeedsBuild();
                                }
                              },
                              child: Text('Edit',
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        itemCount: booking.length);
  }
}
