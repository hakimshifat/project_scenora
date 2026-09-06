# Product Requirements Document (PRD)
## SCENORA — Native Mobile App (Flutter/Dart)

**Version:** 1.0
**Status:** Draft
**Platform:** Android & iOS (single Flutter codebase, Android-first rollout)

---

## 1. Purpose

This PRD defines SCENORA's core purpose, target users, business goals, and high-level feature prioritization so the whole team — design, engineering, and QA — is aligned on a single product vision before implementation begins.

## 2. Product Vision

SCENORA is a native mobile social network for movie and series lovers. It merges discovery (what to watch), community (what people think), and conversation (talking about it live) into one Flutter app, positioned as "Letterboxd meets a live fan chatroom, built mobile-first."

## 3. Business Goals

| Goal | Description | Success Signal |
|---|---|---|
| Community growth | Build an active base of reviewers and followers | Monthly Active Users (MAU), follow-graph density |
| Engagement | Make the app a daily habit for movie fans | Daily Active Users (DAU)/MAU ratio, Shoutbox messages/day |
| Content quality | Encourage thoughtful, frequent reviews | Reviews per active user, average review length |
| Retention | Keep users returning after first session | D1/D7/D30 retention |
| Store presence | Launch cleanly on Google Play (then App Store) | Approval on first submission, crash-free rate |

## 4. Target Users & Personas

- **Rafi, 21, university student (Bangladesh):** Watches 3+ movies/week, wants somewhere to log opinions and see what friends think.
- **Mim, 24, casual viewer:** Wants quick, trustworthy recommendations before picking something to watch tonight.
- **Tanvir, 27, aspiring film critic:** Wants a following, wants his reviews to carry weight, cares about a reviewer reputation system.
- **International fan communities:** Want a live space to talk about releases as they happen (Shoutbox).

## 5. Scope

### 5.1 In Scope (v1 / MVP)
- Auth & onboarding (email/password, Google sign-in)
- Home feed, review posting, ratings, likes/comments/shares
- Follow system, profile screens
- Movie/series discovery via TMDB (search, explore, genre/country/language filters, upcoming/popular/top-rated)
- Movie detail screen with trailer playback
- Watchlist/bookmarking
- Push notifications
- Global Shoutbox (text, image, voice messages) in real time
- Settings & privacy controls
- Offline caching of feed/watchlist for read access

### 5.2 Out of Scope (v1)
- Monetization (ads, subscriptions) — deferred to v2
- Direct/private messaging between users (only global Shoutbox in v1)
- Web application (mobile-first; web is a future consideration)
- Multi-language localization beyond English/Bangla (structure supported, translations deferred)
- Content moderation ML pipeline (manual/report-based moderation for v1)

## 6. Feature Prioritization (MoSCoW)

**Must have**
- Auth, profile, home feed
- Review creation, star ratings
- Movie search & detail screen (TMDB integration)
- Follow/follower, like/comment
- Shoutbox (text minimum)
- Push notifications

**Should have**
- Voice & image messages in Shoutbox
- Watchlist with offline access
- Explore page with genre/country/language filters
- Top Rated Reviewers leaderboard

**Could have**
- Dark/light theme toggle
- Trailer autoplay previews in feed
- Share-to-external-app deep links

**Won't have (v1)**
- In-app purchases
- Private messaging
- Recommendation ML engine

## 7. Key User Stories

1. As a movie fan, I want to write a review with a star rating so others can see my opinion.
2. As a user, I want to follow reviewers I trust so their posts appear prominently in my feed.
3. As a user, I want to search for a movie and see its trailer, cast, and community rating in one screen.
4. As a fan, I want to join a live Shoutbox to discuss a new release as it happens.
5. As a returning user, I want push notifications when someone likes, comments, or follows me.
6. As a user with limited data, I want cached content to be viewable without a live connection.

## 8. Non-Functional Requirements (summary — detailed in SRS)

- App cold start under 2.5s on a mid-range Android device.
- 99.5% crash-free session rate.
- Shoutbox message delivery latency under 1s on stable connections.
- GDPR/local-data-privacy-conscious handling of user content and media.

## 9. Success Metrics

- MAU/DAU growth over first 3 months post-launch.
- Average of 1+ review per active user per month.
- Shoutbox daily message volume as a proxy for community health.
- Crash-free rate ≥ 99.5% (Play Console vitals).
- App Store/Play Store rating ≥ 4.3.

## 10. Release Plan (High-Level)

| Phase | Milestone |
|---|---|
| Alpha | Auth, feed, movie detail, TMDB integration (internal testing) |
| Beta | Reviews, ratings, follow system, Shoutbox (closed beta on Play Console) |
| v1.0 | Notifications, watchlist, offline cache, polish (public Play Store release) |
| v1.1+ | iOS App Store release, localization, monetization exploration |

## 11. Stakeholders

- Product owner / project lead
- Flutter engineering team
- Backend engineering team
- UI/UX designer
- QA/testers
- End users (movie community, beta testers)
