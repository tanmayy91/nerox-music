# Architecture Overview

## Nerox Music — Technical Architecture

Nerox Music is a cross-platform music streaming application built with Flutter, supporting Android, Windows, and Linux platforms.

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.24.2+ (Dart SDK >=3.1.5) |
| **State Management** | GetX |
| **Audio (Android)** | just_audio |
| **Audio (Desktop)** | media_kit via just_audio_media_kit |
| **Background Audio** | audio_service |
| **Local Storage** | Hive (NoSQL) |
| **YouTube API** | youtube_explode_dart |
| **HTTP Client** | Dio |
| **Theming** | Material 3 + Google Fonts (Inter) |

---

## Project Structure

```
lib/
├── base_class/          # Abstract base classes
├── mixins/              # Reusable mixins for controllers
├── models/              # Data models (MediaItem, Album, Playlist, Artist)
├── native_bindings/     # Platform-specific native code (JNI bindings)
├── services/            # Business logic services
│   ├── audio_handler.dart       # Core audio playback logic
│   ├── music_service.dart       # YouTube Music API integration
│   ├── piped_service.dart       # Piped API integration
│   ├── synced_lyrics_service.dart # Lyrics fetching (LRCLIB)
│   ├── downloader.dart          # Song download manager
│   ├── equalizer.dart           # Audio equalizer (Android)
│   └── stream_service.dart      # Stream URL resolution
├── ui/
│   ├── home.dart                # Root widget with SlidingUpPanel
│   ├── navigator.dart           # Nested navigation setup
│   ├── player/                  # Player UI and controllers
│   │   ├── player.dart          # Main player with SlidingUpPanel
│   │   ├── player_controller.dart # Playback state management
│   │   └── components/          # Player sub-components
│   ├── screens/                 # App screens
│   │   ├── Home/                # Home screen with discover content
│   │   ├── Search/              # Search with results
│   │   ├── Library/             # Songs, playlists, albums, artists
│   │   ├── Settings/            # App settings and preferences
│   │   ├── Album/               # Album detail view
│   │   ├── Playlist/            # Playlist detail view
│   │   └── Artists/             # Artist detail view
│   ├── utils/
│   │   └── theme_controller.dart # Theme management (4 modes)
│   └── widgets/                 # Reusable UI components
└── utils/                       # Utilities and helpers
    ├── get_localization.dart     # i18n translations
    ├── helper.dart              # Common utility functions
    └── system_tray.dart         # Desktop system tray
```

---

## State Management

Nerox Music uses the **GetX** pattern for state management:

- **Controllers** extend `GetxController` and hold reactive state (`Rx` observables)
- **Dependency Injection** via `Get.lazyPut()` at app startup, accessed with `Get.find()`
- **Reactive UI** through `Obx()` widgets that rebuild when observables change

### Key Controllers

| Controller | Responsibility |
|-----------|---------------|
| `PlayerController` | Playback state, queue, shuffle, repeat, panel control |
| `HomeScreenController` | Home screen content, tab navigation, discover content |
| `ThemeController` | Theme mode, dynamic colors from album art |
| `SettingsScreenController` | All app preferences and configuration |
| `LibrarySongsController` | Local song library management |
| `LibraryPlaylistsController` | Playlist bookmarks and management |
| `SearchScreenController` | Search queries and results |

---

## Audio Architecture

### Playback Flow
1. User selects a song → `PlayerController.pushSongToQueue()`
2. `AudioHandler` (extends `BaseAudioHandler`) manages playback
3. Stream URL resolved via `youtube_explode_dart`
4. Audio played through `just_audio` (Android) or `media_kit` (Desktop)
5. `audio_service` handles background playback and system media controls

### Prefetching
- At 70% playback progress, the next song's stream URL is prefetched
- Cached in `_prefetchedStreams` map for instant playback transition

### Caching
- Song audio cached to device storage when enabled
- Stream URLs cached in Hive box `SongsUrlCache`
- Home screen data cached in Hive box `homeScreenData`

---

## Theme System

Four theme modes:

| Mode | Description |
|------|------------|
| **Dynamic** | Extracts dominant color from current song's album artwork |
| **System** | Follows device light/dark setting |
| **Dark** | Fixed dark theme — deep blacks (#030304) with electric violet (#9D6BFF) accents |
| **Light** | Fixed light theme — warm cream (#F5F4F0) with charcoal (#141416) text |

Default: **Dark** theme.

All themes use Material 3 design system with Inter font (Google Fonts).

---

## Data Storage

Hive boxes used:

| Box Name | Purpose |
|----------|---------|
| `AppPrefs` | App preferences and settings |
| `SongsCache` | Cached song metadata |
| `SongsUrlCache` | Cached stream URLs |
| `SongDownloads` | Downloaded song records |
| `homeScreenData` | Cached home screen content |
| `lyrics` | Cached lyrics data |

---

## Navigation

- **Mobile**: Bottom navigation bar (Home, Search, Library, Settings)
- **Desktop/Tablet**: Side navigation rail with animated sidebar
- **Nested Navigator** for screen transitions within tabs
- Routes: Home, Search, SearchResult, Album, Playlist, Artist

---

## Platform-Specific

| Feature | Android | Windows | Linux |
|---------|---------|---------|-------|
| Audio Engine | just_audio | media_kit | media_kit |
| Background Audio | audio_service | audio_service | audio_service + MPRIS |
| Equalizer | Native (JNI) | — | — |
| System Tray | — | tray_manager | tray_manager |
| Media Controls | MediaSession | SMTC | MPRIS |
| Auto | Android Auto | — | — |
