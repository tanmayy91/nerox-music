import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

class SyncedLyricsService {
  static const Duration _requestTimeout = Duration(seconds: 8);
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: _requestTimeout,
    receiveTimeout: _requestTimeout,
  ));

  /// Fetch lyrics using multiple sources with fallback.
  /// Sources tried in order:
  ///   1. Local Hive cache
  ///   2. LRCLIB exact match (/api/get)
  ///   3. LRCLIB search (/api/search) — broader fuzzy match
  static Future<Map<String, dynamic>?> getSyncedLyrics(
      MediaItem song, int durInSec) async {
    final lyricsBox = await Hive.openBox("lyrics");
    try {
      // 1. Check local cache
      if (lyricsBox.containsKey(song.id)) {
        return Map<String, dynamic>.from(await lyricsBox.get(song.id));
      }

      final artist = song.artist ?? '';
      final title = song.title;
      final album = song.album ?? '';
      final dur = song.duration?.inSeconds ?? durInSec;

      // 2. Try LRCLIB exact match
      final exactResult = await _tryLrclibExact(artist, title, album, dur);
      if (exactResult != null) {
        printINFO("Lyrics found via LRCLIB exact match");
        await lyricsBox.put(song.id, exactResult);
        return exactResult;
      }

      // 3. Try LRCLIB search (fuzzy / broader)
      final searchResult = await _tryLrclibSearch(artist, title);
      if (searchResult != null) {
        printINFO("Lyrics found via LRCLIB search");
        await lyricsBox.put(song.id, searchResult);
        return searchResult;
      }
    } catch (e) {
      printERROR("Lyrics fetch error: $e");
    } finally {
      await lyricsBox.close();
    }
    return null;
  }

  /// LRCLIB exact match endpoint
  static Future<Map<String, dynamic>?> _tryLrclibExact(
      String artist, String title, String album, int dur) async {
    final url =
        'https://lrclib.net/api/get?artist_name=${Uri.encodeComponent(artist)}&track_name=${Uri.encodeComponent(title)}&album_name=${Uri.encodeComponent(album)}&duration=$dur';
    try {
      final response = (await _dio.get(url)).data;
      if (response is Map) {
        if (response["syncedLyrics"] != null) {
          return {
            "synced": response["syncedLyrics"],
            "plainLyrics": response["plainLyrics"] ?? ""
          };
        }
        if (response["plainLyrics"] != null) {
          return {"synced": "", "plainLyrics": response["plainLyrics"]};
        }
      }
    } on DioException catch (e) {
      printERROR("LRCLIB exact: ${e.message}");
    }
    return null;
  }

  /// LRCLIB search endpoint — tries to find a match by artist + title
  static Future<Map<String, dynamic>?> _tryLrclibSearch(
      String artist, String title) async {
    final query = Uri.encodeComponent('$artist $title');
    final url = 'https://lrclib.net/api/search?q=$query';
    try {
      final response = (await _dio.get(url)).data;
      if (response is List && response.isNotEmpty) {
        // Pick the first result that has synced lyrics, otherwise first with plain
        Map<String, dynamic>? bestPlain;
        for (final item in response) {
          if (item["syncedLyrics"] != null &&
              (item["syncedLyrics"] as String).isNotEmpty) {
            return {
              "synced": item["syncedLyrics"],
              "plainLyrics": item["plainLyrics"] ?? ""
            };
          }
          if (bestPlain == null &&
              item["plainLyrics"] != null &&
              (item["plainLyrics"] as String).isNotEmpty) {
            bestPlain = {"synced": "", "plainLyrics": item["plainLyrics"]};
          }
        }
        if (bestPlain != null) return bestPlain;
      }
    } on DioException catch (e) {
      printERROR("LRCLIB search: ${e.message}");
    }
    return null;
  }
}
