# Functional Specifications Document (FSD)
## SCENORA — Native Mobile App (Flutter/Dart)

**Version:** 1.0

This document translates the PRD/SRS product vision into actionable technical steps: specific user interactions, system behaviors, data handling, and third-party integrations, screen by screen.

---

## 1. App Navigation Structure

Bottom navigation bar (5 tabs), implemented with `go_router` + `NavigationBar` (Material 3):

1. **Home** — social feed
2. **Explore** — movie/series discovery
3. **Shoutbox** — real-time chat
4. **Notifications** — activity inbox
5. **Profile** — current user's profile

A persistent floating action button on Home opens the "Create Review" flow.

---

## 2. Screen-by-Screen Specification

### 2.1 Splash & Onboarding
- **Behavior:** On cold start, check for a valid stored session token (`flutter_secure_storage`). If valid → route to Home. If absent/expired → route to Auth.
- **Onboarding carousel:** 3 swipeable slides introducing Reviews, Ratings, and Shoutbox (shown once, flag stored in Hive).

### 2.2 Authentication
- **Sign Up:** Fields — username, email, password, confirm password. Client-side validation (regex email, min 8-char password). On submit → `POST /auth/register` → store returned JWT + refresh token securely → navigate to Home.
- **Login:** Email/password or "Continue with Google" (Firebase Auth SDK). Failed login shows inline error, not a dialog.
- **Forgot Password:** Triggers backend email reset flow.
- **Data handling:** Password never persisted client-side. Tokens stored via `flutter_secure_storage`, not `SharedPreferences`.

### 2.3 Home Feed
- **Behavior:** Paginated `GET /feed?cursor=...` (cursor-based pagination, 20 items/page). Pull-to-refresh resets cursor. Infinite scroll triggers next page at 80% scroll position.
- **Feed item card:** avatar, username, timestamp, movie poster thumbnail + title, star rating, review text (truncated at 4 lines with "Read more"), image carousel if present, like/comment/share action row.
- **Interactions:**
  - Like → optimistic UI update, `POST /reviews/{id}/like`, rollback on failure.
  - Comment → opens bottom sheet with comment thread + input field.
  - Share → native share sheet (`share_plus`) with deep link `scenora://review/{id}`.

### 2.4 Create Review Flow
- **Step 1:** Search/select a movie (TMDB-backed search, debounced 400ms).
- **Step 2:** Star rating selector (1–5, half-star not supported in v1), review text field (max 2000 chars), optional image attachment (max 4 images, compressed client-side before upload), spoiler toggle.
- **Step 3:** Submit → `POST /reviews` with multipart upload for images → success returns to Home feed with new post prepended.

### 2.5 Explore
- **Sections:** Upcoming, Most Popular, Highest Rated — each a horizontally scrolling carousel backed by `GET /movies/upcoming`, `/movies/popular`, `/movies/top-rated` (proxied/cached TMDB data on backend).
- **Filters:** Genre chips, Country dropdown, Language dropdown — combine into a single filtered query `GET /movies?genre=&country=&language=`.
- **Search bar:** Persistent at top; typing triggers debounced search against `GET /movies/search?q=`.

### 2.6 Movie/Series Detail
- **Data:** `GET /movies/{tmdb_id}` returns synopsis, cast list, trailer YouTube key, TMDB rating, SCENORA average rating (computed from local reviews table), and a paginated list of SCENORA reviews for that title.
- **Trailer playback:** Embedded YouTube player (`youtube_player_flutter`) or native video player if a direct trailer URL is available.
- **Actions:** Bookmark/unbookmark (Watchlist), "Write a Review" CTA, view all reviews for this title.

### 2.7 Watchlist (within Profile or a dedicated tab section)
- **Behavior:** `GET /watchlist` for authenticated fetch; local Drift cache mirrors this list for offline viewing. Adding/removing syncs when connectivity returns (using a simple outbox/retry queue).

### 2.8 Shoutbox
- **Connection:** On tab open, establish WebSocket/Firebase Realtime/Supabase Realtime channel subscription to `shoutbox:global`.
- **Message types:** text, image (uploaded first to storage, message references URL), voice (recorded via `record` package, max 60s, uploaded then referenced by URL, played back with a waveform-style progress bar).
- **Offline handling:** Composed messages while offline are queued in a local outbox (Hive) and flushed in order on reconnect.
- **Rate limiting (client-side UX):** Disable send button for 1s after a message to prevent spam; backend enforces authoritative rate limits.

### 2.9 Notifications
- **Behavior:** `GET /notifications` paginated list; tapping a notification deep-links to the relevant review/profile/comment.
- **Push:** FCM token registered on login (`POST /devices`); notification payload includes a deep-link route.
- **Preferences:** Toggle switches per category (likes, comments, follows, mentions), persisted via `PATCH /users/me/notification-prefs`.

### 2.10 Profile
- **Own profile:** Edit avatar/bio/username, grid of own reviews, followers/following lists (tappable, navigate to a list screen), Top Rated Reviewer badge if threshold met.
- **Other users' profiles:** Follow/unfollow button, same layout minus edit controls, "Report User" option in overflow menu.

### 2.11 Settings
- Theme toggle (light/dark/system)
- Blocked users management
- Notification preferences (mirrors 2.9)
- Account: change password, delete account (confirmation dialog + backend cascade delete), data export request

---

## 3. Third-Party Integration Details

| Integration | Purpose | Notes |
|---|---|---|
| TMDB API | Movie/series metadata, posters, trailers, cast | Proxied through backend to hide API key and enable caching |
| Firebase Auth | Email/password + Google Sign-In | Alternative: custom JWT auth service |
| Firebase Cloud Messaging | Push notifications | Requires `google-services.json` in Android build |
| Firebase Realtime DB / Supabase Realtime | Shoutbox real-time sync | Chosen based on backend decision (see Technical Architecture Doc) |
| Firebase Storage / S3-compatible | Image & voice message storage | Signed upload URLs generated by backend |
| Crashlytics | Crash reporting | Wired at app startup |

---

## 4. Data Handling Rules

- All list endpoints are cursor-paginated; client never requests unbounded result sets.
- Images are compressed client-side (`flutter_image_compress`) to a max of 1080px longest edge before upload.
- Voice messages capped at 60 seconds and compressed to AAC/OGG before upload.
- All user-generated content is soft-deleted server-side first (24h grace window) then hard-deleted, to support "undo delete" and moderation appeals.
- Sensitive tokens never logged; analytics events strip PII before transmission.

---

## 5. Error & Edge Case Handling

- **No connectivity on launch:** Show cached feed (if any) with an offline banner; disable actions requiring network (post, like, comment) with a toast explanation.
- **TMDB API failure/timeout:** Fall back to last cached movie data (backend cache) with a "data may be outdated" indicator.
- **Shoutbox disconnect:** Auto-reconnect with exponential backoff (1s, 2s, 4s... capped at 30s); show connection status indicator.
- **Failed upload (image/voice):** Retry button on the message bubble; message marked "failed" rather than silently dropped.
