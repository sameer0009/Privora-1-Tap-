# API Documentation - Privora Secure (1-Tap)

This document defines the REST API endpoints for the Privora Secure backend.

---

## 1. Authentication (`/auth`)
Base URL: `https://api.privora.io/auth`

### 1.1 Register User (`POST /register`)
Registers a new user and sends a verification email.
- **Body**: `{ "username": "...", "email": "...", "password": "..." }`
- **Response**: `UserObject` (without password)

### 1.2 Login (`POST /login`)
Authenticates user and returns Access and Refresh tokens.
- **Body**: `{ "email": "...", "password": "..." }`
- **Response**: `{ "access_token": "...", "refresh_token": "...", "user": "..." }`

### 1.3 Refresh Token (`POST /refresh`)
Returns a new Access/Refresh token pair using the provided refresh token.
- **Body**: `{ "refresh_token": "..." }`
- **Response**: `{ "access_token": "...", "refresh_token": "..." }`

### 1.4 Verify Email (`GET /verify-email`)
Verifies user identity via token received in email.
- **Query**: `token=<token-uuid>`
- **Response**: `200 OK`

## 2. Device Management (`/devices`)
Base URL: `https://api.privora.io/devices`
Authentication Required: **Bearer Access Token**

### 2.1 Register Device (`POST /register`)
Registers the current device with its identity keys.
- **Body**: `{ "deviceId": "...", "publicKey": "...", "keyExchangeBase": "...", "deviceName": "..." }`
- **Response**: `DeviceObject`

### 2.2 List My Devices (`GET /`)
Returns all active devices for the authenticated user.
- **Response**: `Array<DeviceObject>`

### 2.3 Revoke Device (`DELETE /<deviceId>`)
Removes a device's keys and access from the vault.
- **Response**: `200 OK`

## 3. Profile Management (`/profile`)
Base URL: `https://api.privora.io/profile`
Authentication Required: **Bearer Access Token**

### 3.1 Get Profile (`GET /me`)
Returns current user profile with public fingerprints.
- **Response**: `{ "username": "...", "email": "...", "fingerprint": "..." }`

---
*Privora Secure API Documentation v1.0*
