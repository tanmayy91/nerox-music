<div align="center">

<img src="assets/icons/icon.png" width="120" alt="Nerox Music Logo" />

# Nerox Music

[![Build & Release APK](https://github.com/tanmayy91/Harmony-Music/actions/workflows/build_release.yml/badge.svg)](https://github.com/tanmayy91/Harmony-Music/actions/workflows/build_release.yml)
[![GitHub Pages](https://github.com/tanmayy91/Harmony-Music/actions/workflows/pages.yml/badge.svg)](https://tanmayy91.github.io/Harmony-Music)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version](https://img.shields.io/badge/version-4.0.0-purple.svg)]()

**A premium, cross-platform music streaming experience built with Flutter.**

Stream millions of songs. No ads. No login. No limits.

[Download APK](https://github.com/tanmayy91/Harmony-Music/releases/latest) · [Website](https://tanmayy91.github.io/Harmony-Music) · [Report Bug](https://github.com/tanmayy91/Harmony-Music/issues)

</div>

---

## Download

| Platform | Download |
|----------|----------|
| **Android APK** | [Latest Release](https://github.com/tanmayy91/Harmony-Music/releases/latest) |
| **Android APK (CI Build)** | [Latest Build Artifact](https://github.com/tanmayy91/Harmony-Music/actions/workflows/build_release.yml) |
| **Windows** | [Windows Build](https://github.com/tanmayy91/Harmony-Music/actions/workflows/win_exe.yml) |

> Go to the latest successful workflow run and download **nerox-music-apk** under Artifacts.

---

## Features

### Streaming & Playback
- Stream music from YouTube / YouTube Music
- Background playback with system media controls
- Streaming quality control (Low / High / Best)
- Skip silence for seamless listening
- Equalizer support (Android)
- Android Auto support

### Library & Collections
- Create and manage playlists
- Bookmark albums and artists
- Import songs, playlists, albums, and artists via sharing
- Song download support for offline playback
- Radio feature for endless music discovery

### UI & Experience
- Premium dark theme with electric violet accents
- Dynamic theme that adapts to album artwork
- Smooth animated transitions
- Flexible navigation (bottom bar or side rail)
- Responsive layout for phones, tablets, and desktops
- Synced and plain lyrics display
- Sleep timer

### Privacy & Freedom
- No advertisements
- No login required
- No tracking or data collection
- Piped playlist integration
- Open source under GPL v3.0

### Cross-Platform
- Android
- Windows
- Linux

---

## Translation

<a href="https://hosted.weblate.org/engage/harmony-music/">
<img src="https://hosted.weblate.org/widget/harmony-music/project-translations/multi-auto.svg" alt="Translation status" />
</a>

Help translate Nerox Music — click the badge above or visit the [Weblate project](https://hosted.weblate.org/projects/harmony-music/project-translations/).

---

## Troubleshoot

- If music playback stops due to battery optimization, enable **Ignore Battery Optimization** in Settings > Advanced.

---

## Documentation

Full documentation is available in the [`docs/`](docs/) folder and on the [website](https://tanmayy91.github.io/Harmony-Music).

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Contributing Guide](docs/CONTRIBUTING.md)
- [Build Instructions](docs/BUILD.md)

---

## License

```
Nerox Music is free software licensed under GPL v3.0 with the following conditions:

- Copied/modified versions of this software cannot be used for non-free or profit purposes.
- You cannot publish copied/modified versions on closed source app repositories
  like PlayStore/AppStore.
```

---

## Disclaimer

```
This project is created for educational purposes.
It is not sponsored, affiliated with, funded, authorized, or endorsed by any content provider.
Any song, content, or trademark used in this app is the intellectual property of its respective owners.
Nerox Music is not responsible for any infringement of copyright or other intellectual property rights
that may result from the use of content available through this app.

This software is released "as-is", without any warranty, responsibility, or liability.
```

---

## Credits

**Created by [tanmay](https://instagram.com/tanmaaahy)**

### References
- [Flutter Documentation](https://docs.flutter.dev/) — cross-platform UI framework
- [Suragch](https://suragch.medium.com/) — articles on Just Audio and state management
- [sigma67](https://github.com/sigma67) — unofficial YouTube Music API
- UI inspired by [vfsfitvnm](https://github.com/vfsfitvnm)'s ViMusic
- Synced lyrics by [LRCLIB](https://lrclib.net)
- [Piped](https://piped.video) — playlist integration

### Key Dependencies
| Package | Purpose |
|---------|---------|
| `just_audio` | Audio playback (Android) |
| `media_kit` | Audio playback (Linux/Windows) |
| `audio_service` | Background audio and media controls |
| `get` | State management, DI, routing |
| `youtube_explode_dart` | YouTube stream resolution |
| `hive` | Local database |
| `palette_generator` | Dynamic theming from artwork |

---

<div align="center">

**Made with love by tanmay**

[Instagram](https://instagram.com/tanmaaahy) · [GitHub](https://github.com/tanmayy91)

</div>
