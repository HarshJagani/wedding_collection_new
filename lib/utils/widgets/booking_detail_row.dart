import 'package:flutter/material.dart';

class BookingDetailRow extends StatelessWidget {
  final String keytext;
  final String valuetext;
  const BookingDetailRow({
    super.key,
    required this.keytext,
    required this.valuetext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            keytext,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          )),
          Expanded(child: Text(valuetext))
        ],
      ),
    );
  }
}
