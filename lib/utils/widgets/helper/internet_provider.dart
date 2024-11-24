import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService with ChangeNotifier {
  bool _isConnected = true; // Default to true initially
  late StreamSubscription<InternetStatus> _connectionSubscription;

  bool get isConnected => _isConnected;

  ConnectivityService() {
    _listenToConnectivityChanges();
  }

  // Listen to connectivity changes
  void _listenToConnectivityChanges() {
    _connectionSubscription =
        InternetConnection().onStatusChange.listen((status) {
      _updateConnectivityStatus(status);
    });
  }

  // Update connectivity status and notify listeners
  void _updateConnectivityStatus(InternetStatus status) {
    final isConnected = status == InternetStatus.connected;
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }
}
