# WebSocket Protocol Spec - Privora Secure (1-Tap)

This document defines the WebSocket (Socket.io) signaling protocol for Privora Secure.

---

## 1. Connection Lifecycle
All connections must include a valid JWT in the `auth.token` and a unique `deviceId` in the query parameters.

### 1.1 Handshake
```javascript
const socket = io(URL, {
  auth: { token: 'Bearer <JWT>' },
  query: { deviceId: 'device-uuid' }
});
```

## 2. Signaling Events (WebRTC)
The relay backend acts as a signal-only server for P2P connections.

### 2.1 RTC Offer (`rtc_offer`)
**Direction**: Client A -> Server -> Client B
**Payload**:
```json
{
  "toDeviceId": "recipient-uuid",
  "fromDeviceId": "sender-uuid",
  "offer": { "type": "offer", "sdp": "..." }
}
```

### 2.2 RTC Answer (`rtc_answer`)
**Direction**: Client B -> Server -> Client A
**Payload**:
```json
{
  "toDeviceId": "sender-uuid",
  "fromDeviceId": "recipient-uuid",
  "answer": { "type": "answer", "sdp": "..." }
}
```

### 2.3 ICE Candidate (`rtc_ice_candidate`)
**Direction**: Bi-directional
**Payload**:
```json
{
  "toDeviceId": "peer-uuid",
  "fromDeviceId": "sender-uuid",
  "candidate": { "candidate": "...", "sdpMid": "...", "sdpMLineIndex": 0 }
}
```

## 3. Ephemeral Relay Messaging
For background users or users behind restrictive NAT with no TURN fallback.

### 3.1 Relay Message (`relay_message`)
**Direction**: Client A -> Server -> Client B
**Payload**:
```json
{
  "toDeviceId": "recipient-uuid",
  "messagePayload": { "ciphertext": "...", "nonce": "...", "mac": "..." }
}
```

## 4. Pending Deliveries
Upon connection, the server automatically checks if any messages are buffered for the device.

### 4.1 Pending Messages (`pending_messages`)
**Direction**: Server -> Client
**Payload**: `Array<MessagePayload>` (instantly purged from Redis after emission).

---
*Privora Secure Socket Protocol v1.0*
