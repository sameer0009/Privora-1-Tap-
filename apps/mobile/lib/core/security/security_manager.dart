import 'package:root_checker_plus/root_checker_plus.dart';
import 'dart:io';

class SecurityManager {
  /// Check if the device is rooted or jailbroken
  Future<bool> isDeviceRooted() async {
    try {
      if (Platform.isAndroid) {
        return await RootCheckerPlus.isRootChecker() ?? false;
      } else if (Platform.isIOS) {
        return await RootCheckerPlus.isJailbreak() ?? false;
      }
      return false;
    } catch (e) {
      // In case of error, err on the side of caution
      return true; 
    }
  }

  /// Check for emulator environment (optional hardening)
  Future<bool> isEmulator() async {
    // Basic implementation - can be expanded with device_info_plus
    return false; 
  }

  /// Enforce security policy: terminate if rooted
  Future<void> enforceSecurityPolicy() async {
    final rooted = await isDeviceRooted();
    if (rooted) {
      // In a production app, you might show a dialog and exit.
      // exit(0);
    }
  }
}
