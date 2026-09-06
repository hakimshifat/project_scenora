# UI/UX Design Documentation
## SCENORA — Native Mobile App (Flutter/Dart)

**Version:** 1.0

This document defines wireframe structure, user flows, and design guidelines so the interface adheres to Android (Material 3) user-experience standards — and remains adaptable to iOS conventions — before implementation begins.

---

## 1. Design Principles

1. **Cinema-first visual language:** Dark, poster-forward UI (movie posters and stills are the dominant visual element, similar to a streaming app), with light mode as a secondary option.
2. **Social-native interaction patterns:** Familiar affordances (like, comment, share, follow) so movie fans coming from other social apps feel instantly at home.
3. **Mobile-first speed:** Every core action (rate, review, bookmark) reachable within 2 taps from the Home feed.
4. **Platform-adaptive, not platform-generic:** Material 3 components on Android; Cupertino-style affordances considered for the future iOS build (e.g., swipe-back gestures, iOS-style action sheets).

---

## 2. Information Architecture

```
Root
├── Auth Stack (Splash → Onboarding → Login/Register)
└── Main Shell (Bottom Navigation)
    ├── Home (Feed)
    │   └── Review Detail
    │   └── Create Review (modal flow)
    ├── Explore
    │   ├── Search
    │   ├── Genre/Country/Language filter results
    │   └── Movie/Series Detail
    ├── Shoutbox
    ├── Notifications
    └── Profile
        ├── Edit Profile
        ├── Followers/Following list
        ├── Watchlist
        └── Settings
```

---

## 3. Core User Flows

### 3.1 First-Time User Flow
Splash → Onboarding carousel (3 screens) → Register/Login → Home Feed (empty-state prompting "Follow reviewers or explore movies to get started")

### 3.2 Review Creation Flow
Home (FAB) → Search Movie → Select Movie → Rate & Write Review → Attach Images (optional) → Submit → Return to Home with new post highlighted

### 3.3 Discovery Flow
Explore → Browse carousels or apply filters → Tap movie → Movie Detail → Watch trailer / Read reviews / Bookmark / Write Review

### 3.4 Shoutbox Flow
Shoutbox tab → Live message list (auto-scroll to latest) → Compose (text/image/voice) → Send → Message appears for all connected users in real time

### 3.5 Social Flow
Profile (other user) → Follow → User appears in "Following" list → Their reviews prioritized in Home feed

---

## 4. Wireframe Descriptions (Key Screens)

> Note: Static wireframe image assets (.svg/.fig) referenced below are to be produced by the design team in Figma; this document specifies their required structure and content so engineering and design stay aligned.

**Home Feed (`wireframe_home.svg`)**
- Top app bar: SCENORA logo, search icon, notification bell (with badge)
- Scrollable list of review cards (as specified in FSD §2.3)
- FAB: "+" for new review

**Movie Detail (`wireframe_movie_detail.svg`)**
- Hero header: backdrop image with gradient overlay, poster thumbnail, title, release year
- Rating row: TMDB rating vs. SCENORA community rating, side by side
- Tab strip: Overview | Cast | Reviews
- Sticky bottom bar: Bookmark icon + "Write a Review" button

**Shoutbox (`wireframe_shoutbox.svg`)**
- Chat bubble list (sender avatar left-aligned for others, own messages right-aligned)
- Voice message bubble: waveform + play button + duration
- Composer bar: text field, attach-image icon, hold-to-record mic icon

**Profile (`wireframe_profile.svg`)**
- Cover/avatar header, username, bio, Top Rated Reviewer badge (if applicable)
- Stats row: Posts / Followers / Following (tappable)
- Grid of review posts (poster thumbnails)

**Create Review Modal (`wireframe_create_review.svg`)**
- Movie search field at top
- Star rating selector (large, thumb-friendly)
- Multi-line text field with character counter
- Image attachment thumbnails row
- Spoiler toggle switch
- Primary "Post" button (disabled until rating + movie selected)

---

## 5. Visual Design Guidelines

### 5.1 Color System
- Primary: deep cinematic red/crimson (accent for ratings, CTAs)
- Surface: near-black (#121212) for dark mode; off-white (#FAFAFA) for light mode
- Semantic colors: success/error/warning per Material 3 token roles
- Colors defined as Flutter `ColorScheme` tokens (`ColorScheme.dark()` / `ColorScheme.light()`), never hardcoded hex values in widgets

### 5.2 Typography
- Display/headline: a distinctive, slightly condensed sans-serif for movie titles (e.g., a Google Font such as "Poppins" or "Inter")
- Body text: highly legible sans-serif at 14–16sp
- Type scale follows Material 3 (`TextTheme`) roles: displaySmall, titleLarge, bodyMedium, labelSmall, etc.

### 5.3 Iconography
- Material Symbols (rounded style) as the base icon set, with 2–3 custom icons for brand-specific actions (Shoutbox mic, Top Reviewer badge)

### 5.4 Motion
- Shared-element transitions from feed poster → movie detail hero image (Flutter `Hero` widget)
- Subtle scale/opacity feedback on tap (no jarring transitions)
- Shoutbox new-message entries animate in via slide + fade (`AnimatedList`)

### 5.5 Accessibility
- Minimum contrast ratio 4.5:1 for body text
- All interactive elements minimum 48x48dp hit area
- Semantic labels on icon-only buttons for screen reader support
- Support OS-level font scaling up to at least 130% without layout breakage

---

## 6. Responsive & Adaptive Behavior

- Phone portrait: primary target, single-column layouts
- Tablet/large screen: feed becomes a 2-column masonry-style layout; movie detail uses a side-by-side (poster | info) layout
- Foldables: layout re-flows using `MediaQuery`/`LayoutBuilder` breakpoints rather than fixed device checks

---

## 7. Design Deliverables Checklist

- [ ] Figma file with full screen set (light + dark mode)
- [ ] Component library (buttons, cards, chips, badges, modals)
- [ ] Icon set (SVG, exported at required densities)
- [ ] Motion/prototype flows for the 5 core user flows (Section 3)
- [ ] Design tokens exported to a `theme.dart`-compatible format (JSON) for engineering handoff
