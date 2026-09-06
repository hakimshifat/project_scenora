# Software Requirements Specification (SRS)
## SCENORA — Native Mobile App (Flutter/Dart)

**Version:** 1.0
**Conformance reference:** Structured loosely on IEEE 830 conventions

---

## 1. Introduction

### 1.1 Purpose
This SRS provides the technical blueprint for SCENORA's Flutter mobile application, detailing functional and non-functional requirements, performance benchmarks, scalability targets, security protocols, and database structures.

### 1.2 Scope
Covers the client app (Flutter/Dart, Android & iOS), the backend API, the real-time Shoutbox service, and the data layer. Excludes any future web client.

### 1.3 Definitions
- **Shoutbox:** Global real-time chat feature.
- **Watchlist:** User-saved list of movies/series to view later.
- **TMDB:** The Movie Database, third-party movie metadata API.

---

## 2. Overall Description

### 2.1 Product Perspective
SCENORA is a new, standalone mobile product. The Flutter client communicates with a backend REST/GraphQL API and a real-time service (WebSocket/Firebase/Supabase Realtime) for the Shoutbox, and consumes TMDB as an external data source.

### 2.2 User Classes
- **Guest:** Browse public feed/movie data, cannot post/react.
- **Registered User:** Full feature access (post, rate, follow, chat).
- **Top Rated Reviewer:** Registered user with elevated reputation badge (algorithmic, not a separate permission tier).
- **Admin/Moderator:** Backend role for content moderation, user management.

### 2.3 Operating Environment
- Android 8.0 (API 26) and above; iOS 13 and above (future release).
- Flutter 3.x, Dart 3.x.
- Backend hosted on cloud infrastructure (e.g., AWS/GCP/Render/Fly.io) or managed BaaS (Firebase/Supabase).

### 2.4 Constraints
- Must rely on a licensed third-party API (TMDB) for movie metadata — no scraping.
- Must comply with Google Play Developer Policy and (later) Apple App Store Review Guidelines.
- Voice/image message storage must respect storage cost and size limits (see NFRs).

---

## 3. Functional Requirements

### FR-1 Authentication
- FR-1.1: System shall support registration via email/password.
- FR-1.2: System shall support Google Sign-In (Firebase Auth or equivalent).
- FR-1.3: System shall support biometric app-unlock (fingerprint/face) once logged in.
- FR-1.4: System shall issue and refresh JWT/session tokens securely.

### FR-2 Profile Management
- FR-2.1: Users shall create/edit display name, username, bio, avatar.
- FR-2.2: Profile screen shall display posts, followers, following counts and lists.
- FR-2.3: System shall compute and display a "Top Rated Reviewer" badge based on rating activity/quality thresholds.

### FR-3 Social Feed & Reviews
- FR-3.1: Users shall create a review post containing text, optional images, a 1–5 star rating, and an optional spoiler flag.
- FR-3.2: Feed shall support infinite scroll and pull-to-refresh.
- FR-3.3: Users shall like, comment on, and share posts.
- FR-3.4: Users shall follow/unfollow other users; feed ranking shall prioritize followed users' content.

### FR-4 Movie/Series Discovery
- FR-4.1: System shall integrate TMDB API for search, metadata, cast, trailers, and popularity data.
- FR-4.2: Explore screen shall provide filters by genre, country, and language.
- FR-4.3: System shall display Upcoming, Most Popular, and Highest Rated sections.
- FR-4.4: Movie detail screen shall display synopsis, cast, trailer (in-app playback), TMDB rating, and SCENORA community rating.

### FR-5 Watchlist
- FR-5.1: Users shall bookmark/unbookmark a movie/series.
- FR-5.2: Watchlist shall be viewable offline from local cache.

### FR-6 Notifications
- FR-6.1: System shall send push notifications for likes, comments, follows, and mentions.
- FR-6.2: Users shall configure notification preferences per category.

### FR-7 Shoutbox (Real-Time Chat)
- FR-7.1: System shall provide one global real-time chat channel.
- FR-7.2: Users shall send text, image, and voice messages.
- FR-7.3: Messages shall sync in near real time (target < 1s latency under normal conditions) across connected clients.
- FR-7.4: Offline-composed messages shall queue and send upon reconnect.

### FR-8 Settings & Privacy
- FR-8.1: Users shall block/report other users or content.
- FR-8.2: Users shall toggle dark/light theme.
- FR-8.3: Users shall manage account deletion/data export requests.

---

## 4. Non-Functional Requirements

### 4.1 Performance
- NFR-1: Cold start time ≤ 2.5s on a mid-range Android device (e.g., 4GB RAM, Snapdragon 6-series equivalent).
- NFR-2: Feed pagination requests shall return within 800ms server-side (p95) under normal load.
- NFR-3: Shoutbox message round-trip latency < 1s (p95) on stable 4G/Wi-Fi.

### 4.2 Scalability
- NFR-4: Backend shall horizontally scale to support at least 50,000 concurrent Shoutbox connections at target scale (design target, not initial launch capacity).
- NFR-5: Database schema shall support pagination/indexing suitable for millions of review rows without full-table scans on hot paths.

### 4.3 Security
- NFR-6: All network traffic shall use TLS 1.2+.
- NFR-7: Passwords shall never be stored in plaintext; use bcrypt/Argon2 hashing on the backend.
- NFR-8: JWT access tokens shall be short-lived; refresh tokens stored in secure storage (Flutter `flutter_secure_storage`).
- NFR-9: Media uploads (images/voice) shall be validated for type/size and scanned before public exposure.
- NFR-10: Role-based access control shall gate moderation/admin endpoints.

### 4.4 Reliability & Availability
- NFR-11: Target backend uptime of 99.5% post-launch.
- NFR-12: Crash-free session rate ≥ 99.5% (measured via Firebase Crashlytics or equivalent).

### 4.5 Usability & Accessibility
- NFR-13: UI shall follow Material 3 guidelines on Android and platform-adaptive conventions on iOS.
- NFR-14: Minimum touch target size 48x48dp; text scalable via OS accessibility settings.
- NFR-15: Support for screen readers (Semantics widgets) on primary flows (feed, review creation, movie detail).

### 4.6 Maintainability
- NFR-16: Codebase shall follow a layered architecture (presentation/domain/data) enabling independent testing of layers.
- NFR-17: Minimum 60% unit test coverage on business logic (domain layer) at v1.0.

---

## 5. Data Requirements (Schema Overview)

Core entities:
- **User**(id, username, email, password_hash, avatar_url, bio, created_at, reviewer_score)
- **Movie**(tmdb_id, title, poster_url, genres[], countries[], languages[], release_date, trailer_url, cached_popularity, cached_rating)
- **Review**(id, user_id, movie_id, rating(1-5), text, images[], spoiler_flag, created_at)
- **Comment**(id, review_id, user_id, text, created_at)
- **Like**(id, review_id, user_id)
- **Follow**(follower_id, followee_id)
- **Watchlist**(user_id, movie_id, added_at)
- **ShoutboxMessage**(id, user_id, type[text/image/voice], content_url_or_text, created_at)
- **Notification**(id, user_id, type, payload, read_flag, created_at)

Relational integrity: foreign keys on user_id/movie_id/review_id; cascading delete for a user's own content on account deletion (per privacy compliance).

---

## 6. External Interface Requirements

- **TMDB API:** REST, API key auth, rate-limited — client requests routed through backend to cache responses and avoid exposing API keys in the mobile binary.
- **Firebase Cloud Messaging:** Push notification delivery.
- **Realtime channel (Firebase/Supabase/WebSocket):** Shoutbox message broadcast.
- **Storage (Firebase Storage/S3-compatible):** Image and voice message hosting.

---

## 7. Assumptions & Dependencies

- TMDB API availability and rate limits are sufficient for expected query volume (with backend-side caching).
- Google Play Console developer account is available for distribution.
- Push notification delivery depends on Google Play Services (Android) / APNs (iOS, future).
