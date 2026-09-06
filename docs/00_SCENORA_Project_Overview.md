# SCENORA — A Social Movie & Series Review Platform
## Flutter (Dart) Native Mobile Application — Project Proposal

---

### 1. Project Title

**SCENORA** — A Social Movie & Series Review Platform (Native Mobile App built with Flutter/Dart)

---

### 2. Problem Statement

Movie lovers today are forced to juggle multiple apps to discover movies, check ratings, read reviews, share opinions, and talk to other fans. Most existing apps focus narrowly on movie information or star ratings — none combine discovery, community reviews, social interaction, and real-time discussion into a single, mobile-first experience.

SCENORA solves this by delivering a **native mobile app** (Android & iOS, built from a single Flutter/Dart codebase) that unifies movie/series discovery, user reviews, community ratings, social interaction, personalized profiles, and real-time discussion in one place — optimized for touch, offline caching, push notifications, and mobile performance in ways a web app cannot match.

---

### 3. Target Users

- Movie and series enthusiasts who primarily use smartphones
- Students and young people interested in film culture
- Users who enjoy writing and reading movie reviews on the go
- Users looking for personalized movie/series recommendations
- Users who want to discuss movies live with other fans
- International movie communities, with an initial focus on Bangladesh

---

### 4. Project Objectives

- Deliver a dedicated **native mobile social platform** for movie and series lovers.
- Allow users to post reviews and personal movie experiences from their phones.
- Provide a community-driven movie rating system independent of external scores.
- Help users discover popular, trending, upcoming, and genre/country/language-based movies.
- Allow users to follow other movie lovers and interact with their posts.
- Provide real-time, low-latency communication through the **SCENORA Shoutbox**.
- Consolidate movie metadata — trailers, genres, countries, languages, cast — inside the app.
- Support offline-first browsing (cached feeds, watchlists) suited to mobile network conditions.
- Deliver native push notifications, biometric login, and platform-idiomatic UI (Material 3 / Cupertino).

---

### 5. Major Features / Functionalities

- Onboarding: registration, login (email/password, Google, biometric unlock (Maybe in near future)), profile setup
- Social home feed (infinite scroll, pull-to-refresh)
- Create movie/series review posts (text, images, spoiler tags)
- 1–5 star community movie ratings
- Love (like), comment, and share posts (native share sheet)
- Follow / follower system
- User profile screen with posts, followers, following, and "Top Rated Reviewer" badge
- Movie & series search with debounced queries and filters
- Explore page (trending, genres, countries, languages)
- Upcoming Movies, Most Popular, Highest Rated sections
- Detailed movie/series screen (synopsis, cast, trailer playback, SCENORA rating vs. TMDB rating)
- In-app trailer playback (native video player)
- Bookmarking / Watchlist with offline access
- Push notifications (likes, comments, follows, mentions, shoutbox mentions)
- Real-time global Shoutbox: text, image, and voice messages
- Settings & privacy controls (blocked users, notification preferences, theme)
- Dark mode / light mode, adaptive layouts for phones and tablets
- Smooth native page transitions and micro-interactions (Flutter animations)

---

### 6. Proposed Technology Stack

**Client (Mobile App):**
- Flutter 3.x / Dart 3.x — single codebase for Android & iOS
- State management: Riverpod (or Bloc)
- Navigation: go_router
- Local persistence/offline cache: Drift (SQLite) + Hive for lightweight key-value data
- Networking: Dio + Retrofit-style code generation
- Media: cached_network_image, video_player/chewie, record (voice messages), image_picker

**Backend / API:**
- Node.js (NestJS or Express) REST/GraphQL API, or Firebase/Supabase as managed backend
- WebSocket / Firebase Realtime Database / Supabase Realtime for the Shoutbox
- Authentication: Firebase Auth or custom JWT-based auth with refresh tokens

**Database:**
- PostgreSQL (via Supabase) or Turso/SQLite-compatible managed DB
- Drizzle ORM or Prisma on the backend

**Movie Data:**
- TMDB API (or another legally licensed movie-data API) for movie, series, poster, genre, cast, trailer, and popularity data

**Notifications & Media Storage:**
- Firebase Cloud Messaging (push notifications)
- Firebase Storage / S3-compatible storage for images and voice messages

**Development & Tools:**
- Git & GitHub, GitHub Actions / Codemagic for CI/CD
- Android Studio / VS Code with Flutter & Dart plugins
- Fastlane for store deployment automation

---

### 7. Basic System Workflow

```
User → Splash/Onboarding → Register/Login (email, Google, biometric) → Home Feed
```
From Home, the user can:
- Browse the social review feed
- Love, comment, or share posts
- Follow other users
- Explore movies and series
- Search for titles
- Open a movie's detail screen
- Rate and review a movie
- Save a movie to Watchlist

```
Explore → Genre/Country/Language filter → Movie/Series list → Detail screen → Review/Rate
Profile tab → View/Edit Profile → Posts grid → Followers/Following
Shoutbox tab → Global live conversation → Text/Image/Voice messages → Real-time updates
Notification tab → Likes/Comments/Follows/Mentions → Deep-link to related content
```

---

### 8. Uniqueness / Significance

- A social network built **specifically for** movie and series lovers — not a generic rating site ported to mobile.
- Movie-focused social feed where reviews read like native social media posts.
- Community-driven SCENORA rating, shown alongside (not instead of) external scores.
- "Top Rated Reviewers" leaderboard that highlights trusted, active contributors.
- Global Shoutbox where the whole community shares one real-time conversation, with text, image, and voice messages — built for mobile-native, low-latency interaction and offline queuing.
- Native performance advantages over a web app: push notifications, biometric login, offline caching, smoother animations, and home-screen presence.
- Genre, country, and language-based discovery for personalized browsing.
- A dedicated, mobile-first home for people passionate about cinema.

---

### 9. Feasibility and Project Scope

The project is feasible within the course/development timeline because it can be built incrementally using Flutter's component-driven architecture.

**Initial scope:**
- Authentication & onboarding
- User profiles
- Movie/series discovery (via TMDB integration)
- Reviews and ratings
- Social interactions (like, comment, follow, share)
- Search
- Push notifications
- Shoutbox (real-time chat)
- Local/offline caching
- Backend & database integration

The app will be built natively for **Android first** (with the architecture supporting iOS from day one, since Flutter compiles to both from a single codebase). Existing movie-data APIs (e.g., TMDB) will be used instead of maintaining a manual movie database, keeping development realistic within the available time.

---

### 10. Expected Outcome

The final deliverable is a native Flutter mobile app where users can:

**Discover → Watch (trailers) → Rate → Review → Share → Discuss**

movies and series — all inside one app. SCENORA brings movie discovery, community reviews, ratings, social networking, personalized profiles, movie information, and real-time discussion together into a single native mobile experience, giving movie and series lovers a dedicated community that lives in their pocket.

---

### 11. Companion Documentation Set

This proposal is accompanied by seven supporting documents, each covering a distinct phase of the product lifecycle:

1. **Product Requirements Document (PRD)** — `01_PRD.md`
2. **Software Requirements Specification (SRS)** — `02_SRS.md`
3. **Functional Specifications Document (FSD)** — `03_FSD.md`
4. **UI/UX Design Documentation** — `04_UIUX_Design_Documentation.md`
5. **Technical Architecture Document** — `05_Technical_Architecture_Document.md`
6. **Test Plan & QA Documentation** — `06_Test_Plan_QA_Documentation.md`
7. **Deployment & Compliance Documentation** — `07_Deployment_Compliance_Documentation.md`
