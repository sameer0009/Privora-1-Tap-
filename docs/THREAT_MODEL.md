# Threat Model - Privora Secure (1-Tap)

This document provides a formal threat assessment of the Privora Secure ecosystem using the **STRIDE** methodology.

---

## 1. Threat Profile
- **Assets**: Identity Keys, Session Keys, Ciphertext Payloads, User Metadata.
- **Agents**: External MitM, Malicious Insider (Relay Server Admin), Rooted Device Malware.

## 2. STRIDE Assessment

### 2.1 Spoofing (Identity)
- **Threat**: Attacker spoofs a user's device identity to intercept or send messages.
- **Mitigation**: Every message is signed with the sender's **Ed25519 Identity Key**. The recipient verifies the signature using the registered public key for that device. Identity is anchored to the hardware's secure enclave.

### 2.2 Tampering (Integrity)
- **Threat**: Attacker modifies the ciphertext relay package in transit.
- **Mitigation**: **AES-256-GCM** provides Authenticated Encryption (AEAD). Any tampering with the ciphertext or the associated data (header/nonce) results in an authentication failure during decryption.

### 2.3 Repudiation (Non-repudiation)
- **Threat**: User denies sending a specific secure message.
- **Mitigation**: Digital signatures provide strong non-repudiation. However, since messages are ephemeral and destroyed upon read, the evidence is transient by design to protect privacy.

### 2.4 Information Disclosure (Confidentiality)
- **Threat**: Relay server administrator reads user messages.
- **Mitigation**: **Strict E2EE**. The server only ever sees opaque base64 ciphertext. Plaintext never touches the relay's RAM or disk.
- **Threat**: Recovery of deleted messages from physical disk.
- **Mitigation**: Redis in-memory storage for buffers with **atomic deletion** ensures that once a message is signaled as read, it is zero-filled/purged from memory.

### 2.5 Denial of Service (Availability)
- **Threat**: Flooding the relay gateway to block message delivery.
- **Mitigation**: NestJS Throttler and Rate Limiting on the API and WebSocket gateways. Automatic IP blacklisting for anomalous traffic patterns.

### 2.6 Elevation of Privilege (Access Control)
- **Threat**: User accesses another user's device keys.
- **Mitigation**: **JWT with Refresh Token rotation** and strict `DeviceId` query validation on the WebSocket handshake. Cross-user device access is blocked at the Prisma/Postgres layer via strict Query Filters.

---
*Privora Secure Threat Model v1.0*
Reference: STRIDE Methodology
