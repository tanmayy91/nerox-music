import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Payload keys — sync ──────────────────────────────────────────────────────
const _kSongId = 'songId';
const _kSongTitle = 'songTitle';
const _kSongArtist = 'songArtist';
const _kThumbnailUrl = 'thumbnailUrl';
const _kPositionMs = 'positionMs';
const _kDurationMs = 'durationMs';
const _kIsPlaying = 'isPlaying';
const _kSentAtMs = 'sentAtMs';

// ─── Payload keys — chat ──────────────────────────────────────────────────────
const _kChatRole = 'role';
const _kChatText = 'text';
const _kChatTs = 'ts';

/// [ListenTogetherService] manages ephemeral Supabase Realtime Broadcast
/// channels to sync music playback between two devices — no login required.
///
/// Design:
///  • Host creates a room (6-char code) → broadcasts sync every 2 s.
///  • Guest joins with the code → receives sync events and mirrors playback.
///  • Both host and guest can send / receive chat messages on the same channel.
///  • Everything is ephemeral: no data is stored in any database.
class ListenTogetherService extends GetxService {
  RealtimeChannel? _channel;

  // ── Observables consumed by the UI ───────────────────────────────────────
  final roomCode = RxnString();
  final isHost = false.obs;
  final isInRoom = false.obs;
  final lastSync = Rxn<SyncPayload>();
  final membersOnline = 0.obs;

  // ── Callbacks wired by ListenTogetherController ──────────────────────────
  void Function(SyncPayload)? onSyncReceived;
  VoidCallback? onHostEnded;
  void Function(ChatMessage)? onChatReceived;

  SupabaseClient get _client => Supabase.instance.client;

  // ── Room creation (HOST) ─────────────────────────────────────────────────

  Future<String> createRoom() async {
    await leaveRoom();
    final code = _generateCode();
    roomCode.value = code;
    isHost.value = true;

    _channel = _client.channel('lt-$code',
        opts: const RealtimeChannelConfig(ack: false));

    _channel!
      // Host listens for chat messages from guest.
      ..onBroadcast(
        event: 'chat',
        callback: (payload) => _handleChat(payload),
      )
      // Track presence for member count.
      ..onPresenceSync((_) {
        membersOnline.value = _channel!.presenceState().length;
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _channel!.track({'role': 'host'});
          isInRoom.value = true;
        }
      });

    return code;
  }

  // ── Room joining (GUEST) ─────────────────────────────────────────────────

  Future<void> joinRoom(String code) async {
    await leaveRoom();
    final upper = code.trim().toUpperCase();
    roomCode.value = upper;
    isHost.value = false;

    _channel = _client.channel('lt-$upper',
        opts: const RealtimeChannelConfig(ack: false));

    _channel!
      ..onBroadcast(
        event: 'sync',
        callback: (payload) {
          try {
            final parsed = SyncPayload.fromMap(payload);
            lastSync.value = parsed;
            onSyncReceived?.call(parsed);
          } catch (e) {
            debugPrint('ListenTogether: bad sync payload: $e');
          }
        },
      )
      ..onBroadcast(
        event: 'chat',
        callback: (payload) => _handleChat(payload),
      )
      ..onBroadcast(
        event: 'end',
        callback: (_) {
          onHostEnded?.call();
        },
      )
      ..onPresenceSync((_) {
        membersOnline.value = _channel!.presenceState().length;
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _channel!.track({'role': 'guest'});
          isInRoom.value = true;
        }
      });
  }

  // ── Broadcasting ─────────────────────────────────────────────────────────

  /// Sync broadcast — host only.
  Future<void> broadcastSync(SyncPayload payload) async {
    if (!isInRoom.value || !isHost.value || _channel == null) return;
    await _channel!
        .sendBroadcastMessage(event: 'sync', payload: payload.toMap());
  }

  /// Chat broadcast — both host and guest can call this.
  Future<void> broadcastChat(ChatMessage msg) async {
    if (!isInRoom.value || _channel == null) return;
    await _channel!
        .sendBroadcastMessage(event: 'chat', payload: msg.toMap());
  }

  // ── Leave / end ──────────────────────────────────────────────────────────

  Future<void> leaveRoom() async {
    if (_channel == null) return;
    try {
      if (isHost.value) {
        await _channel!.sendBroadcastMessage(event: 'end', payload: {});
      }
      await _client.removeChannel(_channel!);
    } catch (_) {}
    _channel = null;
    roomCode.value = null;
    isHost.value = false;
    isInRoom.value = false;
    lastSync.value = null;
    membersOnline.value = 0;
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  void _handleChat(Map<String, dynamic> payload) {
    try {
      final msg = ChatMessage.fromMap(payload);
      onChatReceived?.call(msg);
    } catch (e) {
      debugPrint('ListenTogether: bad chat payload: $e');
    }
  }

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SyncPayload
// ─────────────────────────────────────────────────────────────────────────────

class SyncPayload {
  final String songId;
  final String songTitle;
  final String songArtist;
  final String thumbnailUrl;
  final int positionMs;
  final int durationMs;
  final bool isPlaying;
  final int sentAtMs;

  const SyncPayload({
    required this.songId,
    required this.songTitle,
    required this.songArtist,
    required this.thumbnailUrl,
    required this.positionMs,
    required this.durationMs,
    required this.isPlaying,
    required this.sentAtMs,
  });

  factory SyncPayload.fromMap(Map<String, dynamic> m) => SyncPayload(
        songId: m[_kSongId] as String? ?? '',
        songTitle: m[_kSongTitle] as String? ?? '',
        songArtist: m[_kSongArtist] as String? ?? '',
        thumbnailUrl: m[_kThumbnailUrl] as String? ?? '',
        positionMs: (m[_kPositionMs] as num?)?.toInt() ?? 0,
        durationMs: (m[_kDurationMs] as num?)?.toInt() ?? 0,
        isPlaying: m[_kIsPlaying] as bool? ?? false,
        sentAtMs: (m[_kSentAtMs] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => {
        _kSongId: songId,
        _kSongTitle: songTitle,
        _kSongArtist: songArtist,
        _kThumbnailUrl: thumbnailUrl,
        _kPositionMs: positionMs,
        _kDurationMs: durationMs,
        _kIsPlaying: isPlaying,
        _kSentAtMs: sentAtMs,
      };

  /// Playback position corrected for the network round-trip time since
  /// the host sent this payload.
  Duration get correctedPosition {
    final drift = DateTime.now().millisecondsSinceEpoch - sentAtMs;
    final adjusted = positionMs + (isPlaying ? drift : 0);
    return Duration(
        milliseconds: adjusted.clamp(0, durationMs > 0 ? durationMs : adjusted));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatMessage
// ─────────────────────────────────────────────────────────────────────────────

class ChatMessage {
  /// 'host' or 'guest'
  final String senderRole;
  final String text;
  final int ts;

  const ChatMessage({
    required this.senderRole,
    required this.text,
    required this.ts,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        senderRole: m[_kChatRole] as String? ?? 'guest',
        text: m[_kChatText] as String? ?? '',
        ts: (m[_kChatTs] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => {
        _kChatRole: senderRole,
        _kChatText: text,
        _kChatTs: ts,
      };
}
