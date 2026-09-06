# Deployment & Compliance Documentation
## SCENORA — Native Mobile App (Flutter/Dart)

**Version:** 1.0

Prepares release assets for the Google Play Store — app descriptions, screenshots, privacy policy, and signed Android App Bundle (AAB) release instructions — with notes for a future Apple App Store submission.

---

## 1. Google Play Console Setup

1. Create a Google Play Developer account (one-time $25 registration fee).
2. Create a new app entry: name **SCENORA**, default language English (add Bangla as an additional listing language).
3. Complete the **App content** section:
   - Privacy policy URL (see Section 5)
   - Ads declaration (No ads in v1)
   - Content rating questionnaire (expect **Teen** rating due to user-generated content/social features)
   - Target audience & content (13+ recommended given social/UGC features)
   - Data safety form (see Section 6)
   - Government apps / COVID-19 apps: Not applicable

---

## 2. Store Listing Assets

### 2.1 App Description (Short — 80 chars max)
> "Rate, review, and discuss movies & series with a live community of fans."

### 2.2 App Description (Full)
> SCENORA is a social network built for movie and series lovers. Discover trending, upcoming, and highest-rated titles, write reviews with star ratings, follow reviewers you trust, and join the global Shoutbox to talk about what you're watching — live, with text, images, and voice messages. One app for discovering, rating, reviewing, and discussing everything you watch.

### 2.3 Graphic Assets Checklist
- [ ] App icon (512x512 PNG, no transparency, adaptive icon layers for Android)
- [ ] Feature graphic (1024x500 PNG/JPG)
- [ ] Phone screenshots — minimum 2, recommended 6–8 (1080x1920 or device-native resolution): Home feed, Movie detail, Create review, Explore, Shoutbox, Profile
- [ ] Tablet screenshots (optional but recommended, 7" and 10")
- [ ] Promo video (optional, YouTube link)

### 2.4 Categorization
- Category: **Entertainment** (secondary consideration: Social)
- Tags/keywords: movies, series, reviews, ratings, film community, watchlist

---

## 3. Signed Release Build — Android App Bundle (AAB)

### 3.1 Generate an Upload Keystore (one-time)
```bash
keytool -genkey -v -keystore ~/scenora-upload-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias scenora-upload
```
Store the keystore and its passwords in a secure secrets manager (e.g., 1Password, GitHub Actions encrypted secrets) — **never commit to version control**.

### 3.2 Configure Signing in `android/key.properties`
```properties
storePassword=<store-password>
keyPassword=<key-password>
keyAlias=scenora-upload
storeFile=/absolute/path/to/scenora-upload-key.jks
```
Reference this file from `android/app/build.gradle` under `signingConfigs.release`, and ensure `key.properties` is listed in `.gitignore`.

### 3.3 Build the Release AAB
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 3.4 Enable Play App Signing
- Opt in to **Play App Signing** during first upload so Google manages the app signing key while the developer retains the upload key — this is Google's recommended and default flow.

### 3.5 Upload & Release Tracks
1. Upload the AAB to the **Internal testing** track first; verify install and smoke test.
2. Promote to **Closed testing** (beta) with the tester group defined in the QA plan (Section 9 of the Test Plan doc).
3. After exit criteria are met (zero P0/P1 bugs, crash-free ≥ 99.5%), promote to **Production**, initially with a staged rollout (e.g., 20% → 50% → 100%) to catch issues early.

### 3.6 Versioning
- `pubspec.yaml` version format: `versionName+versionCode`, e.g. `1.0.0+1`.
- Increment `versionCode` on every Play Store upload; `versionName` follows semantic versioning for user-facing release notes.

---

## 4. Fastlane Automation (Recommended)

`android/fastlane/Fastfile` example lane:
```ruby
platform :android do
  desc "Build and upload a release AAB to Play Console internal testing"
  lane :internal do
    sh("flutter build appbundle --release")
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: ENV['PLAY_STORE_JSON_KEY']
    )
  end
end
```
Integrated into the CI pipeline (GitHub Actions) so a tagged release (e.g., `v1.0.0`) triggers an automatic upload to the internal testing track.

---

## 5. Privacy Policy Requirements

The privacy policy (hosted at a public URL, linked in Play Console) must disclose:
- What personal data is collected (email, username, profile info, reviews, uploaded images/voice messages, device/push token, optional location if added later)
- Purpose of collection (account functionality, social features, push notifications)
- Third parties data is shared with (TMDB — for content only, not personal data; Firebase/Google — for auth, storage, push, analytics)
- Data retention and deletion policy (linked to account deletion flow in FSD §2.11)
- User rights (access, export, deletion requests) and contact method for privacy requests
- Children's privacy statement (app not directed at children under 13; age-gating during registration if required by target market regulations)

---

## 6. Play Console Data Safety Form (Summary Mapping)

| Data Type | Collected? | Shared? | Purpose |
|---|---|---|---|
| Email address | Yes | No | Account management, auth |
| User-generated content (reviews, images, voice) | Yes | No (public within app only) | App functionality (social feed) |
| Approximate/precise location | No (v1) | — | — |
| Photos/media | Yes | No | Review images, Shoutbox media |
| Audio | Yes | No | Shoutbox voice messages |
| Device/other IDs (FCM token) | Yes | With Google (FCM) | Push notifications |
| Analytics identifiers | Yes | With Firebase/Google or PostHog | Product analytics |

All data in transit encrypted (TLS/WSS per Technical Architecture Doc §8); users can request account/data deletion in-app (Settings, per FSD §2.11).

---

## 7. Permissions Disclosure (maps to Technical Architecture §7)

Play Console requires justification for sensitive permissions:
- **Microphone (RECORD_AUDIO):** Required for recording voice messages in the Shoutbox feature.
- **Camera:** Required for capturing photos to attach to reviews or Shoutbox messages.
- **Notifications (POST_NOTIFICATIONS):** Required to alert users of likes, comments, follows, mentions.

Each permission is requested contextually at first use, not on app launch, per Play policy best practice.

---

## 8. Compliance Checklist Before Submission

- [ ] Privacy policy published and linked
- [ ] Data safety form completed and matches actual data practices
- [ ] Content rating questionnaire completed
- [ ] Target API level meets current Play Store requirement (Android 14 / API 34 target at time of writing — verify current requirement before submission, as Google updates this annually)
- [ ] App tested on minimum supported OS (Android 8.0 / API 26) and does not crash on launch
- [ ] All permissions have contextual runtime rationale
- [ ] Signed release AAB built via the process in Section 3
- [ ] Store listing assets (Section 2) finalized and uploaded
- [ ] Crash reporting (Crashlytics) verified active in the release build

---

## 9. Post-Launch: Future Apple App Store Notes (v1.1+)

- Requires an Apple Developer Program account ($99/year).
- App Store Connect listing mirrors the Play Console assets (Section 2) with iOS-specific screenshot sizes (6.7", 6.5", 5.5" device classes).
- iOS build requires `ios/Runner/Info.plist` entries for camera (`NSCameraUsageDescription`), microphone (`NSMicrophoneUsageDescription`), and notifications, mirroring the Android manifest permissions.
- App Store Review Guidelines require an in-app account deletion path (already satisfied per FSD §2.11) and a functioning privacy policy link.
- TestFlight used for closed beta distribution, mirroring the Play Console closed-testing track process in Section 3.5.
