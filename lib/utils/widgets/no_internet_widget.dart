import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wedding_collection_new/utils/widgets/helper/internet_provider.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final Widget? noConnectionWidget;

  const ConnectivityWrapper(
      {super.key, required this.child, this.noConnectionWidget});

  @override
  Widget build(BuildContext context) {
    bool isConnected = true;
    isConnected = Provider.of<ConnectivityService>(context).isConnected;
    return isConnected
        ? child
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/vayo_ja.gif',
                width: double.maxFinite,
              ),
              SizedBox(
                height: 20,
              ),
              Text('વયો જા એય...',
                  style: Theme.of(context).textTheme.headlineLarge)
            ],
          );
  }
}
