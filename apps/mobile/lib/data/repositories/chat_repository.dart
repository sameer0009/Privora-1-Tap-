import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import '../../core/security/crypto_service.dart';
import '../../core/network/api_client.dart';
import '../../domain/models/user_model.dart';

class ChatRepository {
  final ApiClient _api;
  final CryptoService _crypto;
  
  // In-memory session keys (Industry level would persist these in encrypted local DB or secure cache)
  final Map<String, SecretKey> _activeSessions = {};

  ChatRepository(this._api, this._crypto);

  Future<void> sendMessage({
    required String peerDeviceId,
    required String peerPublicKey, // Ed25519
    required String message,
  }) async {
    // 1. Get or create session key
    SecretKey? sessionKey = _activeSessions[peerDeviceId];
    if (sessionKey == null) {
      // In a real flow, we'd perform DH. For this build, we use the peer's exchange base.
      final peerExchangeKey = await _getPeerExchangeKey(peerDeviceId);
      final myExchangeKeyPair = await _crypto.generateExchangeKey();
      
      sessionKey = await _crypto.deriveSessionKey(myExchangeKeyPair, {
        'publicKey': peerExchangeKey,
      });
      _activeSessions[peerDeviceId] = sessionKey;
    }

    // 2. Encrypt message
    final encryptedData = await _crypto.encryptMessage(message, sessionKey);

    // 3. Prepare payload for relay
    final relayPayload = {
      'toDeviceId': peerDeviceId,
      'messagePayload': {
        'senderDeviceId': 'my_device_id', // Would be loaded from store
        'encrypted': encryptedData,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'text',
      }
    };

    // 4. Dispatch via API or WebSocket (RelayGateway)
    await _api.client.post('/relay/send', data: relayPayload);
  }

  Future<String?> decryptIncomingMessage({
    required String senderDeviceId,
    required Map<String, dynamic> encryptedPayload,
  }) async {
    SecretKey? sessionKey = _activeSessions[senderDeviceId];
    if (sessionKey == null) return null; // Logic to handle missing session key (rerun DH)

    try {
      final cleartext = await _crypto.decryptMessage(
        encryptedPayload['ciphertext'],
        encryptedPayload['nonce'],
        encryptedPayload['mac'],
        sessionKey,
      );
      return cleartext;
    } catch (e) {
      return null;
    }
  }

  Future<String> _getPeerExchangeKey(String deviceId) async {
    // Call backend to query the device's public keys
    final response = await _api.client.get('/devices/$deviceId');
    return response.data['keyExchangeBase'];
  }
}
