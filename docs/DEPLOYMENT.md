# Deployment Guide - Privora Secure (1-Tap)

This document provides instructions for deploying the Privora Secure platform in a production environment.

---

## 1. Prerequisites
- **Docker & Docker Compose**: Version 20.10+ and 2.x+
- **SSL Certificate**: A valid TLS certificate (e.g., Let's Encrypt) for the backend and frontend.
- **SMTP Credentials**: Provided by an industry-standard provider (e.g., SendGrid, AWS SES).

## 2. Infrastructure (Docker Compose)
Launch the persistent and ephemeral layers in detached mode:
```bash
docker-compose --file docker-compose.prod.yml up -d
```
The production stack includes:
- **Postgres (v15)**: Persistent vault metadata.
- **Redis (v7)**: High-speed ephemeral message relay.
- **NestJS Server**: The core signaling and auth relay.

## 3. Environment Configuration
Create a `.env.production` file in the backend root:
```env
# Database
DATABASE_URL="postgresql://admin:password@localhost:5432/onetap?schema=public"
REDIS_URL="redis://localhost:6379"

# Security
JWT_SECRET="<generate-random-64-char-string>"
JWT_REFRESH_SECRET="<generate-random-64-char-string>"
ENCRYPTION_KEY="<generate-random-32-char-string>"

# Communication
SMTP_HOST="smtp.sendgrid.net"
SMTP_PORT=587
SMTP_USER="apikey"
SMTP_PASS="<your-sendgrid-api-key>"

# Networking
PORT=3001
CORS_ORIGIN="https://privora.io"
```

## 4. Mobile Client (Flutter)
Build the production APK or iOS App Bundle:

### 4.1 Android Production APK
```bash
flutter build apk --release --split-per-abi
```

### 4.2 iOS Production Archive
```bash
flutter build ipa --release
```

## 5. Continuous Integration (GitHub Actions)
A sample CI/CD workflow (`.github/workflows/deploy.yml`) is provided to:
1. Run backend unit and integration tests.
2. Build the Docker image.
3. Push to a container registry (GHCR/DockerHub).
4. Update the production server via SSH.

---
*Privora Secure Deployment Guide v1.0*
