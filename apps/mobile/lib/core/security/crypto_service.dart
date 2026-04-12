import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  final _storage = const FlutterSecureStorage();
  final _x25519 = X25519();
  final _ed25519 = Ed25519();
  final _aesGcm = AesGcm.with256bits();

  /// Generates the X25519 keypair for session negotiation
  Future<SimpleKeyPair> generateExchangeKey() async {
    return await _x25519.newKeyPair();
  }

  /// Perform Diffie-Hellman exchange and derive session key using HKDF
  Future<SecretKey> deriveSessionKey(SimpleKeyPair myExchangeKeyPair, Map<String, dynamic> peerExchangePublicKeyBytes) async {
    final remotePublicKey = SimplePublicKey(
      base64Decode(peerExchangePublicKeyBytes['publicKey']),
      type: KeyPairType.x25519,
    );

    // Compute shared secret via DH
    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: myExchangeKeyPair,
      remotePublicKey: remotePublicKey,
    );

    // HKDF Expand to 256-bit AES key
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derivedKey = await hkdf.deriveKey(
      secretKey: sharedSecret,
      info: utf8.encode('privora-v1-session-key'),
    );

    return derivedKey;
  }

  /// Sign a message using Identity Key (Ed25519)
  Future<String> signMessage(String message, SimpleKeyPair identityKeyPair) async {
    final signature = await _ed25519.sign(
      utf8.encode(message),
      keyPair: identityKeyPair,
    );
    return base64Encode(signature.bytes);
  }

  /// Verify a message signature
  Future<bool> verifySignature(String message, String signatureBase64, String publicKeyBase64) async {
    final signature = Signature(
      base64Decode(signatureBase64),
      publicKey: SimplePublicKey(base64Decode(publicKeyBase64), type: KeyPairType.ed25519),
    );
    return await _ed25519.verify(utf8.encode(message), signature: signature);
  }

  /// Encrypt a message using AES-GCM
  Future<Map<String, dynamic>> encryptMessage(String message, SecretKey sessionKey) async {
    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(message),
      secretKey: sessionKey,
      nonce: nonce,
    );
    
    return {
      'ciphertext': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  /// Decrypt a message using AES-GCM
  Future<String> decryptMessage(String ciphertextBase64, String nonceBase64, String macBase64, SecretKey sessionKey) async {
    final secretBox = SecretBox(
      base64Decode(ciphertextBase64),
      nonce: base64Decode(nonceBase64),
      mac: Mac(base64Decode(macBase64)),
    );
    
    final cleartext = await _aesGcm.decrypt(
      secretBox,
      secretKey: sessionKey,
    );
    
    return utf8.decode(cleartext);
  }

  /// Generate Identity Key
  Future<SimpleKeyPair> generateIdentityKey() async {
    return await _ed25519.newKeyPair();
  }

  /// Extract Public Key string
  Future<String> getPublicKeyString(SimpleKeyPair keyPair) async {
    final pubKey = await keyPair.extractPublicKey();
    return base64Encode(pubKey.bytes);
  }
}
