# Test Plan & QA Documentation
## SCENORA — Native Mobile App (Flutter/Dart)

**Version:** 1.0

Outlines test cases, scenarios, device matrices, and automation scripts to ensure reliability across a range of Android devices and API levels (with iOS coverage added at the v1.1 milestone).

---

## 1. Testing Objectives

- Verify all functional requirements in the FSD behave correctly across supported devices/OS versions.
- Verify non-functional targets from the SRS (performance, crash-free rate, security basics) are met before release.
- Catch regressions automatically via CI before merge to main.

## 2. Test Levels & Tooling

| Level | Tooling | Scope |
|---|---|---|
| Unit tests | `flutter_test`, `mocktail` | Domain use-cases, repositories (mocked data sources), utility functions |
| Widget tests | `flutter_test` | Individual screens/widgets in isolation (e.g., review card renders rating correctly) |
| Integration tests | `integration_test` package, Patrol (optional) | End-to-end flows on a real/emulated device |
| Backend API tests | Jest/Supertest (Node) or Firebase emulator suite | Endpoint contract & auth validation |
| Manual/exploratory QA | Test case checklist (below) | UX edge cases, visual QA, device-specific quirks |
| Performance | Flutter DevTools, Firebase Performance Monitoring | Startup time, frame rendering (jank), network latency |
| Security | Manual review + `flutter_secure_storage` audit, dependency scanning | Token handling, permission usage |

Target coverage: ≥ 60% line coverage on domain/data layers (per SRS NFR-17), enforced via CI coverage gate.

---

## 3. Device & OS Matrix (Android-first)

| Tier | Example Devices | Android Version | Priority |
|---|---|---|---|
| Low-end | Samsung Galaxy A13, Redmi 10 | Android 12 (API 31) | High |
| Mid-range | Samsung Galaxy A54, Redmi Note 12 | Android 13 (API 33) | High |
| High-end | Samsung Galaxy S23/S24, Pixel 8 | Android 14 (API 34) | Medium |
| Minimum supported | Any device | Android 8.0 (API 26) | High (compatibility check) |
| Tablet | Samsung Galaxy Tab A9 | Android 13 | Medium |

*iOS matrix (added at v1.1):* iPhone SE (small screen), iPhone 14 (standard), iPhone 15 Pro (Dynamic Island/notch handling), iOS 16 & 17.

Testing performed via a mix of physical devices, Firebase Test Lab, and Android Emulator (API 26, 31, 33, 34 images).

---

## 4. Key Test Scenarios by Feature

### 4.1 Authentication
- Register with valid/invalid email formats
- Password strength validation messaging
- Login with correct/incorrect credentials
- Google Sign-In success and cancellation flow
- Token refresh after access-token expiry
- Biometric unlock enable/disable and fallback to password

### 4.2 Feed & Reviews
- Feed loads and paginates correctly (scroll to end triggers next page)
- Pull-to-refresh resets and reloads feed
- Create review with text only / text + images / with spoiler flag
- Like/unlike updates count optimistically and reconciles with server
- Comment thread loads, posts, and updates in real time
- Offline: feed shows cached data with offline banner; posting is disabled/queued appropriately

### 4.3 Explore / Movie Detail
- Search returns relevant TMDB results with debounce (no request per keystroke)
- Genre/country/language filters combine correctly
- Movie detail loads synopsis, cast, trailer, and both rating sources
- Trailer playback starts/stops/pauses correctly; handles missing trailer gracefully
- Bookmark/unbookmark reflects immediately and persists after app restart

### 4.4 Shoutbox
- Text message send/receive across two simulated clients
- Image message upload/send/receive and correct rendering
- Voice message record (max 60s enforced), upload, playback, and waveform display
- Reconnect behavior after network loss (auto-reconnect, queued messages flush in order)
- Rate-limit / spam protection behavior (server rejects, client shows appropriate error)

### 4.5 Notifications
- Push notification received for like/comment/follow/mention while app is backgrounded/closed
- Tapping a notification deep-links to the correct screen
- Notification preference toggles suppress the correct categories

### 4.6 Profile & Settings
- Edit profile fields persist and reflect across app (feed, comments, etc.)
- Follow/unfollow updates counts and feed content correctly
- Theme toggle applies instantly without restart
- Account deletion removes/soft-deletes user content per SRS §5 and confirms via a two-step dialog

---

## 5. Non-Functional / Performance Test Cases

- Cold start time measured on low-end and mid-range tier devices (target ≤ 2.5s per SRS NFR-1)
- Frame rendering: no dropped-frame jank (>16.6ms frame time) during feed scroll, measured via DevTools timeline
- Shoutbox message latency measured end-to-end under Wi-Fi and throttled 3G conditions
- Memory profiling during extended Shoutbox session (checking for leaks in image/voice message list)
- App size audit (APK/AAB size) to keep install footprint reasonable

## 6. Security Test Checklist

- Verify no sensitive tokens appear in logs (debug and release builds)
- Verify auth tokens stored only in secure storage, not `SharedPreferences`
- Verify all API calls use HTTPS/WSS (no cleartext traffic — enforced via Android Network Security Config)
- Verify runtime permission prompts (camera, mic, notifications) show rationale and handle "deny" gracefully without crashing
- Dependency vulnerability scan (`flutter pub outdated` / `dart pub audit` equivalent, and backend `npm audit`)

## 7. Automation & CI Pipeline

- GitHub Actions workflow triggers on PR: `flutter analyze` → `flutter test` (unit + widget) → coverage report upload.
- Nightly job: `integration_test` suite run against Firebase Test Lab across the device matrix (Section 3).
- Pre-release job: build signed AAB, run smoke test suite, upload to Play Console internal testing track automatically (Fastlane).

## 8. Bug Triage & Severity Definitions

| Severity | Definition | Example |
|---|---|---|
| Critical (P0) | Crash, data loss, security issue, blocks core flow | App crashes on login |
| High (P1) | Major feature broken, no workaround | Shoutbox fails to send messages |
| Medium (P2) | Feature partially broken, workaround exists | Filter combination returns wrong results |
| Low (P3) | Cosmetic/minor UX issue | Misaligned padding on a card |

Exit criteria for release: zero open P0/P1 bugs, crash-free rate ≥ 99.5% in the beta track over a 7-day window (per SRS NFR-12).

## 9. Beta Testing Plan

- Closed beta via Google Play Console internal/closed testing track (50–200 testers from the target movie-fan community).
- Feedback collected via in-app "Report a bug" (screenshot + logs attached) and a shared feedback form.
- Beta exit criteria matches Section 8's release exit criteria.
