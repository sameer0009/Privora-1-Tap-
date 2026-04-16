import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

enum CustomConnectivityStatus { wifi, mobile, none }

class ConnectivityNotifier extends Notifier<CustomConnectivityStatus> {
  final _connectivity = Connectivity();
  StreamSubscription? _subscription;

  @override
  CustomConnectivityStatus build() {
    _init();
    return CustomConnectivityStatus.none;
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        _updateStatus(results);
      }
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    CustomConnectivityStatus newStatus;
    if (results.contains(ConnectivityResult.wifi)) {
      newStatus = CustomConnectivityStatus.wifi;
      debugPrint('Privora: Network switched to WiFi');
    } else if (results.contains(ConnectivityResult.mobile)) {
      newStatus = CustomConnectivityStatus.mobile;
      debugPrint('Privora: Network switched to Mobile Data');
    } else {
      newStatus = CustomConnectivityStatus.none;
      debugPrint('Privora: No internet connection');
    }
    state = newStatus;
  }

  bool get isConnected => state != CustomConnectivityStatus.none;
  bool get isOnWifi => state == CustomConnectivityStatus.wifi;

  void dispose() {
    _subscription?.cancel();
  }
}

final connectivityServiceProvider = NotifierProvider<ConnectivityNotifier, CustomConnectivityStatus>(() {
  return ConnectivityNotifier();
});
