# System Architecture - Privora Secure (1-Tap)

This document describes the high-level architecture of the Privora Secure platform.

---

## 1. Top-Level Overview
Privora Secure is a distributed ecosystem consisting of a Flutter mobile client and a NestJS relay backend. It is designed for zero-retention ephemeral messaging with military-grade E2EE.

### 1.1 Architecture Diagram
```mermaid
graph TD
    A[Flutter App] <-->|Signaling / Relay| B[NestJS Relay Gateway]
    A <-->|Direct P2P (mDNS)| A
    B <-->|Atomic Storage| C[(Redis Cache)]
    B <-->|Persistent Metadata| D[(Postgres DB)]
    A <-->|Direct P2P (WebRTC)| A
```

## 2. Component Breakdown

### 2.1 Flutter Mobile Client
- **Presentation**: Riverpod Notifiers for state, Material 3 with Premium Dark Theme.
- **Domain**: Clean Architecture entities for Users, Devices, and Messages.
- **Data**: Dio for REST, Socket.io for Real-time, nsd for Local Discovery.
- **Security**: 
  - `CryptoService`: X25519 (DH), Ed25519 (Signatures), AES-256-GCM.
  - `AuthManager`: Biometric lock & Encrypted Secure Storage.
  - `SecurityManager`: Root/Jailbreak detection.

### 2.2 NestJS Relay Backend
- **Gateway**: Handles real-time signaling for WebRTC and one-time message relays.
- **Auth**: JWT with Refresh Toker rotation and Industry SMTP verification.
- **Device Management**: Tracks multi-device public keys and fingerprints.
- **Infrastructure**:
  - **Redis**: Acts as an atomic, auto-expiring buffer for one-time read messages.
  - **PostgreSQL**: Stores non-sensitive metadata (Users, Device public keys).

## 3. Communication Protocols
- **REST (HTTPS)**: Used for Auth, Profile management, and Device registration.
- **WebSockets (WSS)**: Used for Signaling (WebRTC offers/answers) and active message delivery.
- **WebRTC (P2P)**: Used for direct DataChannel communication and file transfers when both peers are online.
- **mDNS (Local)**: Used to discover peers on the same subnet without requiring an internet connection.

---
*Privora Secure Architecture v1.0*
