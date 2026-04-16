import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/services/listen_together_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/snackbar.dart';

/// Maximum position drift before the guest seeks to re-sync (ms).
/// At 200 ms, both players stay within one broadcast interval of each other.
const _kSyncDriftThresholdMs = 200;

class ListenTogetherController extends GetxController {
  final _service = Get.find<ListenTogetherService>();

  // ── UI state forwarded from service ──────────────────────────────────────
  RxnString get roomCode => _service.roomCode;
  RxBool get isHost => _service.isHost;
  RxBool get isInRoom => _service.isInRoom;
  Rxn<SyncPayload> get lastSync => _service.lastSync;
  RxInt get membersOnline => _service.membersOnline;

  // ── Local UI state ────────────────────────────────────────────────────────
  final isConnecting = false.obs;
  final codeInputController = TextEditingController();

  // ── Chat ─────────────────────────────────────────────────────────────────
  final messages = <ChatMessage>[].obs;
  final chatInputController = TextEditingController();

  // ── Live position (guest side) ────────────────────────────────────────────
  /// Estimated current position in ms, updated every second from lastSync
  /// plus elapsed time so the progress bar animates smoothly without waiting
  /// for the next broadcast.
  final livePositionMs = 0.obs;
  final liveDurationMs = 0.obs;
  final liveIsPlaying = false.obs;

  // ── Internal timers ───────────────────────────────────────────────────────
  Timer? _hostTimer;
  Timer? _guestLiveTicker;

  // ── Track last synced song id to avoid redundant loads ───────────────────
  String? _lastSyncedSongId;

  // ── Timestamp when lastSync was received (used for live ticker) ───────────
  int _syncReceivedAt = 0;

  @override
  void onInit() {
    super.onInit();
    _service.onSyncReceived = _handleGuestSync;
    _service.onHostEnded = _handleHostEnded;
    _service.onChatReceived = _handleChatReceived;
  }

  @override
  void onClose() {
    codeInputController.dispose();
    chatInputController.dispose();
    _stopHostTimer();
    _stopGuestTicker();
    super.onClose();
  }

  // ── HOST actions ─────────────────────────────────────────────────────────

  Future<void> createRoom() async {
    isConnecting.value = true;
    messages.clear();
    try {
      await _service.createRoom();
      _startHostTimer();
      _broadcastNow();
    } catch (e) {
      _showSnack('ltConnectError'.tr);
    } finally {
      isConnecting.value = false;
    }
  }

  /// Build and send an immediate sync payload.
  void _broadcastNow() {
    if (!_service.isInRoom.value || !_service.isHost.value) return;
    final player = _tryGetPlayer();
    if (player == null) return;
    final song = player.currentSong.value;
    if (song == null) return;

    final payload = SyncPayload(
      songId: song.id,
      songTitle: song.title,
      songArtist: song.artist ?? '',
      thumbnailUrl: song.artUri?.toString() ?? '',
      positionMs: player.progressBarStatus.value.current.inMilliseconds,
      durationMs: player.progressBarStatus.value.total.inMilliseconds,
      isPlaying: player.buttonState.value == PlayButtonState.playing,
      sentAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    _service.broadcastSync(payload);
  }

  /// Broadcast every 500 ms for near-real-time synchronisation with no
  /// audible gap between both users' playback positions.
  void _startHostTimer() {
    _stopHostTimer();
    _hostTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _broadcastNow();
    });
  }

  void _stopHostTimer() {
    _hostTimer?.cancel();
    _hostTimer = null;
  }

  // ── GUEST actions ────────────────────────────────────────────────────────

  Future<void> joinRoom() async {
    final code = codeInputController.text.trim().toUpperCase();
    if (code.length != 6) {
      _showSnack('ltInvalidCode'.tr);
      return;
    }
    isConnecting.value = true;
    messages.clear();
    try {
      await _service.joinRoom(code);
      _startGuestTicker();
    } catch (e) {
      _showSnack('ltConnectError'.tr);
    } finally {
      isConnecting.value = false;
    }
  }

  /// Manually re-sync the guest to the host's last known position.
  Future<void> syncNow() async {
    final sync = _service.lastSync.value;
    if (sync == null) return;
    await _applySync(sync, force: true);
    _showSnack('ltSyncedNow'.tr);
  }

  // ── Guest live-position ticker ────────────────────────────────────────────

  /// Runs every 200 ms on the guest side. Recalculates the estimated playback
  /// position from the last known sync + elapsed time so the progress bar is
  /// smooth and both users appear to be at the exact same moment of the song.
  void _startGuestTicker() {
    _stopGuestTicker();
    _guestLiveTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final sync = _service.lastSync.value;
      if (sync == null) return;

      liveDurationMs.value = sync.durationMs;
      liveIsPlaying.value = sync.isPlaying;

      if (!sync.isPlaying) {
        livePositionMs.value = sync.positionMs;
        return;
      }

      final elapsedSinceSync =
          DateTime.now().millisecondsSinceEpoch - _syncReceivedAt;
      final estimated = sync.positionMs + elapsedSinceSync;
      livePositionMs.value =
          estimated.clamp(0, sync.durationMs > 0 ? sync.durationMs : estimated);
    });
  }

  void _stopGuestTicker() {
    _guestLiveTicker?.cancel();
    _guestLiveTicker = null;
  }

  // ── Incoming sync handler (guest) ─────────────────────────────────────────

  void _handleGuestSync(SyncPayload payload) {
    _syncReceivedAt = DateTime.now().millisecondsSinceEpoch;
    _applySync(payload, force: false);
  }

  Future<void> _applySync(SyncPayload payload, {required bool force}) async {
    if (payload.songId.isEmpty) return;
    final player = _tryGetPlayer();
    if (player == null) return;
    final handler = _tryGetHandler();

    // ── Load a new song if the host changed track ─────────────────────────
    if (payload.songId != _lastSyncedSongId || force) {
      final current = player.currentSong.value;
      if (current?.id != payload.songId) {
        final mediaItem = MediaItem(
          id: payload.songId,
          title: payload.songTitle,
          artist: payload.songArtist,
          artUri: payload.thumbnailUrl.isNotEmpty
              ? Uri.tryParse(payload.thumbnailUrl)
              : null,
          duration: payload.durationMs > 0
              ? Duration(milliseconds: payload.durationMs)
              : null,
        );
        await player.pushSongToQueue(mediaItem);
        // Give playback a moment to begin before seeking.
        await Future.delayed(const Duration(milliseconds: 800));
      }
      _lastSyncedSongId = payload.songId;
    }

    // ── Seek only when drift exceeds threshold ────────────────────────────
    if (handler != null) {
      final target = payload.correctedPosition;
      final total = Duration(milliseconds: payload.durationMs);

      if (force) {
        // Manual sync — always seek.
        if (total > Duration.zero && target <= total) {
          await handler.seek(target);
        }
      } else {
        // Auto-sync — seek only if drift is noticeable.
        final currentMs =
            player.progressBarStatus.value.current.inMilliseconds;
        final drift = (target.inMilliseconds - currentMs).abs();
        if (drift > _kSyncDriftThresholdMs &&
            total > Duration.zero &&
            target <= total) {
          await handler.seek(target);
        }
      }
    }

    // ── Mirror play/pause state ───────────────────────────────────────────
    if (handler != null) {
      final playing = player.buttonState.value == PlayButtonState.playing;
      if (payload.isPlaying && !playing) {
        await handler.play();
      } else if (!payload.isPlaying && playing) {
        await handler.pause();
      }
    }
  }

  void _handleHostEnded() {
    _stopGuestTicker();
    _showSnack('ltHostEnded'.tr);
    _service.leaveRoom();
    messages.clear();
  }

  // ── Leave ─────────────────────────────────────────────────────────────────

  Future<void> leaveRoom() async {
    _stopHostTimer();
    _stopGuestTicker();
    _lastSyncedSongId = null;
    messages.clear();
    await _service.leaveRoom();
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  Future<void> sendMessage() async {
    final text = chatInputController.text.trim();
    if (text.isEmpty) return;
    chatInputController.clear();

    final msg = ChatMessage(
      senderRole: _service.isHost.value ? 'host' : 'guest',
      text: text,
      ts: DateTime.now().millisecondsSinceEpoch,
    );

    // Add to local list immediately for instant feedback.
    messages.add(msg);

    // Broadcast to the other party.
    await _service.broadcastChat(msg);
  }

  void _handleChatReceived(ChatMessage msg) {
    // Only add if the message came from the other party (we already added ours).
    final myRole = _service.isHost.value ? 'host' : 'guest';
    if (msg.senderRole != myRole) {
      messages.add(msg);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void copyCode() {
    final code = _service.roomCode.value;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    _showSnack('ltCodeCopied'.tr);
  }

  PlayerController? _tryGetPlayer() {
    try {
      return Get.find<PlayerController>();
    } catch (_) {
      return null;
    }
  }

  AudioHandler? _tryGetHandler() {
    try {
      return Get.find<AudioHandler>();
    } catch (_) {
      return null;
    }
  }

  void _showSnack(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        snackbar(Get.context!, message, size: SanckBarSize.MEDIUM),
      );
    }
  }
}
