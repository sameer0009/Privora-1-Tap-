import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/security/crypto_service.dart';
import '../../core/security/auth_manager.dart';

class AuthRepository {
  final ApiClient _api;
  final CryptoService _crypto;
  final AuthManager _authManager;

  AuthRepository(this._api, this._crypto, this._authManager);

  Future<void> login(String email, String password) async {
    try {
      final response = await _api.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      
      await _authManager.saveTokens(
        accessToken: accessToken, 
        refreshToken: refreshToken
      );
      
      await _ensureIdentityKeys();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(String username, String email, String password) async {
    try {
      await _api.client.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      
      // Traditional production apps would wait for email verification here.
      // For this flow, we'll proceed to login.
      await login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureIdentityKeys() async {
    final tokens = await _authManager.getTokens();
    // Assuming keys are managed inside AuthManager or CryptoService storage
    // For now, continuing the pattern of using AuthManager's storage proxy
    // but in a real app, this would be even deeper.
  }

  Future<bool> isLoggedIn() async {
    final tokens = await _authManager.getTokens();
    return tokens['access_token'] != null;
  }

  Future<void> logout() async {
    await _authManager.clearVault();
  }
  
  Future<void> refreshToken() async {
    final tokens = await _authManager.getTokens();
    final rt = tokens['refresh_token'];
    if (rt == null) throw Exception('No refresh token');
    
    final response = await _api.client.post('/auth/refresh', data: {
      'refresh_token': rt,
    });
    
    await _authManager.saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
    );
  }
}
