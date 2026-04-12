# 1-Tap Project Status

Here is a comprehensive list of what has been created for the **1-Tap** platform so far, organized by its monorepo structure:

### 📁 Project Root
The project is set up as a monorepo to manage the different applications and shared packages.
- `package.json`, `package-lock.json` - Root dependency management
- `docker-compose.yml` - Container orchestration (likely for Redis and the backend)
- `.env.example` - Environment variable template

---

### 💻 1. Frontend Web App (`apps/frontend`)
A modern Next.js web application implementing the zero-retention WebCrypto client.
- **Pages & Routing:**
  - `src/app/page.tsx` & `layout.tsx` - Main landing experience
  - `src/app/auth/page.tsx` - Authentication and cryptographic key generation
  - `src/app/dashboard/page.tsx` & `layout.tsx` - The secure communication dashboard
- **Core Logic (`src/lib`):**
  - `crypto.ts` - WebCrypto API implementation for local encryption/decryption
  - `socket.ts` - WebSocket client for real-time communication
- **UI Components:**
  - `src/components/ui/button.tsx` - Reusable UI component base

### ⚙️ 2. Backend Server (`apps/backend`)
A hardened Node.js/TypeScript backend API.
- **Entry point:** `src/app.ts` and `src/index.ts`
- **Services:** `src/services/redis.service.ts` - Redis integration used to facilitate the ephemeral (zero-retention) message storage and pub/sub.
- **Middleware:** `src/middleware/errorHandler.ts` & `src/middleware/validate.ts` - Request validation and security controls.
- **Utilities:** `src/utils/logger.ts` and `src/config/env.ts`

### 📱 3. Mobile App (`apps/mobile`)
A native Flutter application architected to maintain full cryptographic parity with the web client.
- **Core Sources (`lib/`):**
  - `main.dart` - Main entry point and application UI
  - `crypto_service.dart` - Secure platform-native cryptography logic
  - `socket_service.dart` - Real-time communication handlers

### 📦 4. Shared Packages (`packages/`)
- **`crypto-utils`:** Shared utilities for cryptography setup.
- **`shared-types`:** Shared data structures/interfaces to maintain type safety between the frontend and backend.
