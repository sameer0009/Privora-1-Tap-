import 'package:flutter_test/flutter_test.dart';
import '../lib/core/security/crypto_service.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:convert';

void main() {
  late CryptoService crypto;

  setUp(() {
    crypto = CryptoService();
  });

  group('CryptoService E2EE Tests', () {
    test('Identity Key Generation - Should return valid Ed25519 keys', () async {
      final keyPair = await crypto.generateIdentityKey();
      final pubKey = await keyPair.extractPublicKey();
      
      expect(pubKey.bytes, isNotEmpty);
      expect(pubKey.type, KeyPairType.ed25519);
    });

    test('Full DH Exchange & AES-GCM Flow - Two users should be able to communicate', () async {
      // User A
      final aliceExchangeKeyPair = await crypto.generateExchangeKey();
      final alicePub = await aliceExchangeKeyPair.extractPublicKey();

      // User B
      final bobExchangeKeyPair = await crypto.generateExchangeKey();
      final bobPub = await bobExchangeKeyPair.extractPublicKey();

      // Exchange logic
      final aliceDerivedSecret = await crypto.deriveSessionKey(
        aliceExchangeKeyPair, 
        {'publicKey': base64Encode(bobPub.bytes)}
      );

      final bobDerivedSecret = await crypto.deriveSessionKey(
        bobExchangeKeyPair, 
        {'publicKey': base64Encode(alicePub.bytes)}
      );

      // Verify Session Key Parity
      final aliceSecretBytes = await aliceDerivedSecret.extractBytes();
      final bobSecretBytes = await bobDerivedSecret.extractBytes();
      expect(aliceSecretBytes, equals(bobSecretBytes));

      // Test Encryption/Decryption
      const originalMessage = "Secret protocol 1-Tap";
      final encrypted = await crypto.encryptMessage(originalMessage, aliceDerivedSecret);
      
      final decrypted = await crypto.decryptMessage(
        encrypted['ciphertext'],
        encrypted['nonce'],
        encrypted['mac'],
        bobDerivedSecret,
      );

      expect(decrypted, equals(originalMessage));
    });

    test('Signature Verification - Should verify message authenticity', () async {
      final identityKey = await crypto.generateIdentityKey();
      final pubKeyStr = await crypto.getPublicKeyString(identityKey);
      const message = "Authentic source";

      final signature = await crypto.signMessage(message, identityKey);
      final isValid = await crypto.verifySignature(message, signature, pubKeyStr);

      expect(isValid, isTrue);

      final isInvalid = await crypto.verifySignature("Tampered message", signature, pubKeyStr);
      expect(isInvalid, isFalse);
    });
  });
}
