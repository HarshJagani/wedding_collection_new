import 'package:flutter/material.dart';

class NoBookingWidget extends StatelessWidget {
  const NoBookingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/sad-face.png',
          height: 50,
          width: 50,
        ),
        SizedBox(height: 10),
        Text(
          'No dates booked yet!',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
