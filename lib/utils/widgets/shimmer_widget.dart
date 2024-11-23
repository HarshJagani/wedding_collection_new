import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white10
          : Colors.black12,
      highlightColor:Theme.of(context).brightness == Brightness.dark
          ? Colors.white12
          : Colors.black26,
      child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 7,
              mainAxisSpacing: 10),
          itemCount: 6,
          itemBuilder: (context, index) => Card()),
    );
  }
}
