# Security Model - Privora Secure (1-Tap)

This document outlines the cryptographic and security infrastructure of the Privora Secure platform.

---

## 1. End-to-End Encryption (E2EE)
Privora Secure implements a strict E2EE model where the relay server never receives plaintext.

### 1.1 Key Management
- **Identity Key (IK)**: Ed25519 keypair generated locally. Used for message signing and identity verification.
- **Key Exchange (DH)**: X25519 keypair generated for session negotiation.
- **Session Keys**: Derived using **HKDF-SHA256** from the X25519 shared secret. 
- **Storage**: All private keys are stored in the device's **Secure Enclave** (iOS Keychain / Android Keystore) via `FlutterSecureStorage`.

### 1.2 Message Encryption (AES-256-GCM)
Messages are encrypted using Authenticated Encryption with Associated Data (AEAD) via AES-256-GCM. 
- **Nonce**: A unique 96-bit nonce is generated for every message. 
- **MAC**: A 128-bit Authentication Tag ensures message integrity and authenticity.

## 2. Zero-Retention (Relay Layer)
The backend is designed for zero persistence of sensitive communications.

### 2.1 Atomic Consumption
When the mobile client retrieves a message from the relay:
- The relay server performs an **atomic Redis `get` then `del`** operation.
- The message is purged from memory and disk before the client even receives the payload.

### 2.2 Transience
All buffered messages are configured with a hard **24-hour TTL**. 
- Undelivered messages are automatically destroyed by the Redis eviction policy.

## 3. Device Security & Hardening
- **Biometric Locking**: Access to the local vault requires a successful biometric challenge.
- **Root/Jailbreak Detection**: The app verifies system integrity on startup and blocks access if tampering is detected.
- **Certificate Pinning**: The `ApiClient` enforces SSL pinning to prevent Man-in-the-Middle (MitM) attacks.
- **Memory Safety**: Decrypted message content is wiped from memory as soon as the session is closed.

---
*Privora Secure Security Model v1.0*
