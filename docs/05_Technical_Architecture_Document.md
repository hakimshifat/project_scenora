# Technical Architecture Document
## SCENORA — Native Mobile App (Flutter/Dart)

**Version:** 1.0

Describes the chosen tech stack, API endpoints, data flow, backend integration strategy, and required Android manifest declarations for hardware/software permissions.

---

## 1. High-Level Architecture

```
┌─────────────────────────────┐
│      Flutter Client App     │
│  (Android / iOS, Dart 3.x)  │
│                              │
│  Presentation (Widgets)     │
│  ── Riverpod (state) ──     │
│  Domain (use cases/models)  │
│  Data (repositories)        │
│  ├── Remote: Dio (REST)     │
│  ├── Realtime: WS/Firebase  │
│  └── Local: Drift + Hive    │
└──────────────┬───────────────┘
               │ HTTPS / WSS
               ▼
┌─────────────────────────────┐
│         Backend API          │
│  Node.js (NestJS) or         │
│  Firebase/Supabase Functions │
│  - REST endpoints             │
│  - Auth service               │
│  - Realtime Shoutbox gateway  │
│  - TMDB proxy/cache layer     │
└──────┬─────────────┬─────────┘
       │              │
       ▼              ▼
┌─────────────┐  ┌──────────────┐
│  PostgreSQL /│  │  TMDB API    │
│  Turso (SQLite│ │ (external)   │
│  compatible)  │ └──────────────┘
└─────────────┘
       │
       ▼
┌─────────────────────────────┐
│ Storage (Firebase Storage /  │
│ S3-compatible) + FCM push    │
└─────────────────────────────┘
```

---

## 2. Client Architecture (Flutter)

**Pattern:** Clean Architecture, 3 layers per feature module:
- **Presentation:** Widgets + Riverpod `Notifier`/`AsyncNotifier` classes, no business logic in widgets.
- **Domain:** Plain Dart use-case classes and entity models, framework-agnostic (unit-testable without Flutter bindings).
- **Data:** Repository implementations, remote data sources (Dio clients), local data sources (Drift DAOs, Hive boxes), and DTO ↔ entity mappers.

**Folder structure (feature-first):**
```
lib/
  core/            (theming, routing, network client, error handling)
  features/
    auth/
    feed/
    reviews/
    explore/
    movie_detail/
    shoutbox/
    notifications/
    profile/
    watchlist/
    settings/
  shared/          (reusable widgets, extensions)
main.dart
```

**Navigation:** `go_router` with typed routes, deep-link support for `scenora://review/{id}`, `scenora://movie/{tmdb_id}`, `scenora://profile/{username}` (used by push notifications and share links).

**Local storage:**
- **Drift (SQLite):** structured, queryable cache — feed items, movie details, watchlist, offline outbox queues.
- **Hive:** lightweight key-value data — onboarding flags, theme preference, draft review text.
- **flutter_secure_storage:** auth tokens only.

---

## 3. Backend Architecture

**Option A — Custom backend (Node.js/NestJS):**
- REST API with modules: `auth`, `users`, `reviews`, `movies` (TMDB proxy/cache), `shoutbox` (WebSocket gateway via `socket.io` or native `ws`), `notifications` (FCM sender), `media` (signed upload URLs).
- ORM: Prisma or Drizzle against PostgreSQL (or Turso/SQLite-compatible for smaller-scale deployments).
- Deployed on a container platform (e.g., Render, Fly.io, or AWS ECS).

**Option B — Managed BaaS (Firebase/Supabase):**
- Firebase Auth for identity; Firestore/Realtime Database for social graph and Shoutbox; Cloud Functions for TMDB proxy/cache and notification triggers; Firebase Storage for media.
- Faster to stand up, trades some flexibility for managed scaling.

*Recommendation:* Start with Option B (Firebase/Supabase) for MVP velocity, with the data layer designed so the client's repository interfaces are backend-agnostic — enabling a later migration to Option A if custom business logic or cost at scale requires it.

---

## 4. API Endpoint Summary (REST, Option A style — equivalent Cloud Functions/Firestore rules apply under Option B)

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/auth/register` | Create account |
| POST | `/auth/login` | Authenticate, issue tokens |
| POST | `/auth/refresh` | Refresh access token |
| GET | `/users/me` | Current user profile |
| PATCH | `/users/me` | Update profile |
| GET | `/users/{id}` | Public profile |
| POST | `/users/{id}/follow` | Follow/unfollow |
| GET | `/feed` | Paginated home feed |
| POST | `/reviews` | Create review |
| POST | `/reviews/{id}/like` | Like/unlike review |
| POST | `/reviews/{id}/comments` | Add comment |
| GET | `/movies/search` | TMDB-backed search (proxied) |
| GET | `/movies/{tmdb_id}` | Movie detail + SCENORA aggregate rating |
| GET | `/movies/upcoming` \| `/popular` \| `/top-rated` | Discovery lists |
| GET | `/watchlist` / POST `/watchlist` | Manage watchlist |
| GET | `/notifications` | Notification inbox |
| POST | `/devices` | Register FCM token |
| WS | `/shoutbox` | Real-time chat channel |
| POST | `/media/upload-url` | Get signed upload URL for image/voice |

---

## 5. Data Flow Examples

**Posting a review:**
Client (Create Review screen) → compress images locally → request signed upload URL(s) → upload directly to storage → `POST /reviews` with storage URLs + rating/text → backend persists row, recalculates movie's aggregate SCENORA rating → response cached locally in Drift → feed screen invalidates/refetches.

**Shoutbox message:**
Client → WebSocket `emit('message', payload)` → backend validates/rate-limits → broadcasts to all subscribed clients → each client appends to local `AnimatedList` and persists to Drift for scrollback.

---

## 6. Third-Party Integrations

- **TMDB API:** all calls proxied through backend; backend caches responses (e.g., 6–24h TTL) to reduce TMDB rate-limit pressure and hide the API key from the client binary.
- **Firebase Cloud Messaging:** push delivery; client registers/refreshes device token on login and token-refresh events.
- **Crashlytics/Sentry:** crash and non-fatal error reporting from the Flutter client.
- **Analytics:** Firebase Analytics or PostHog for funnel/engagement tracking (PII-stripped events per FSD §4).

---

## 7. Android Manifest Declarations

The following permissions/features are required in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.VIBRATE" />

<uses-feature
    android:name="android.hardware.microphone"
    android:required="false" />
<uses-feature
    android:name="android.hardware.camera"
    android:required="false" />
```

Notes:
- `RECORD_AUDIO` and `CAMERA` are runtime-requested (via `permission_handler`) with clear in-context rationale dialogs before the OS prompt, per Play Store policy.
- `POST_NOTIFICATIONS` runtime permission required on Android 13+ for push notifications to display.
- No `READ_EXTERNAL_STORAGE`/`WRITE_EXTERNAL_STORAGE` broad permissions are requested; scoped storage APIs and `image_picker`/`file_picker` are used instead.

---

## 8. Security Architecture

- TLS enforced on all client-server traffic; certificate pinning considered for v1.1+.
- Access tokens short-lived (e.g., 15 min); refresh tokens rotated and stored in `flutter_secure_storage` (Android Keystore-backed).
- Backend input validation on all endpoints (e.g., `class-validator` for NestJS or Zod for Node/Firebase Functions).
- Rate limiting on auth and Shoutbox endpoints to mitigate abuse/spam.
- Signed, time-limited URLs for all media uploads/downloads rather than public write access to storage buckets.

---

## 9. Scalability Considerations

- Stateless backend instances behind a load balancer (Option A) or auto-scaling managed functions (Option B).
- Read-heavy endpoints (feed, movie detail) cached at the CDN/edge layer where possible.
- Shoutbox realtime layer designed to shard by channel if/when multiple rooms are introduced post-v1.
- Database indexes on `movie_id`, `user_id`, `created_at` for feed/review queries; TMDB response cache table to avoid redundant external calls.
