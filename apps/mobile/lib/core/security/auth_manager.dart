import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class AuthManager {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  /// Check if biometrics are available and configured
  Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Perform biometric challenge
  Future<bool> authenticateBiometrically() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Access your Privora Vault',
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Securely store token
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Retrieve tokens
  Future<Map<String, String?>> getTokens() async {
    final at = await _storage.read(key: 'access_token');
    final rt = await _storage.read(key: 'refresh_token');
    return {'access_token': at, 'refresh_token': rt};
  }

  /// Clear all secure storage
  Future<void> clearVault() async {
    await _storage.deleteAll();
  }
}
