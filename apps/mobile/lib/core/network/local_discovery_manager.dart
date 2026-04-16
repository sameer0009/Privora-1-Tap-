import 'dart:convert';
import 'package:nsd/nsd.dart';
import 'package:flutter/foundation.dart';

class LocalDiscoveryManager {
  static const String serviceType = '_privora-secure._tcp';
  Registration? _registration;
  Discovery? _discovery;

  /// Start advertising this device on the local network (mDNS)
  Future<void> advertiseDevice(String deviceId, String name) async {
    try {
      _registration = await register(
        Service(
          name: name,
          type: serviceType,
          port: 8080, // Target port for P2P communication
          txt: {'deviceId': Uint8List.fromList(utf8.encode(deviceId))},
        ),
      );
      debugPrint('Privora: Advertising device as $name ($deviceId)');
    } catch (e) {
      debugPrint('Privora: Local advertising failed: $e');
    }
  }

  /// Discover other Privora devices on the same network
  Future<void> discoverDevices(Function(Service) onDeviceFound) async {
    try {
      _discovery = await startDiscovery(serviceType);
      _discovery?.addServiceListener((service, status) {
        if (status == ServiceStatus.found) {
          onDeviceFound(service);
        }
      });
    } catch (e) {
      debugPrint('Privora: Local discovery failed: $e');
    }
  }

  /// Stop all local networking activity
  Future<void> stopAll() async {
    if (_registration != null) await unregister(_registration!);
    if (_discovery != null) await stopDiscovery(_discovery!);
  }
}
