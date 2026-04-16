import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/listen_together_service.dart';
import '/ui/player/player_controller.dart';
import 'listen_together_controller.dart';

class ListenTogetherScreen extends StatelessWidget {
  const ListenTogetherScreen({super.key, this.isBottomNavActive = false});
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ListenTogetherController());
    final topPadding = context.isLandscape ? 50.0 : 90.0;

    return Padding(
      padding: isBottomNavActive
          ? EdgeInsets.only(left: 20, top: topPadding, right: 15)
          : EdgeInsets.only(top: topPadding, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              const SizedBox(width: 6),
              const Icon(Icons.headphones_rounded, size: 28),
              const SizedBox(width: 10),
              Text('listenTogether'.tr,
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              'listenTogetherTagline'.tr,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.55),
                  ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (ctrl.isInRoom.value) {
                return _InRoomView(ctrl: ctrl);
              }
              return _LobbyView(ctrl: ctrl);
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lobby — before joining / creating a room
// ─────────────────────────────────────────────────────────────────────────────

class _LobbyView extends StatelessWidget {
  const _LobbyView({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
              tabs: [
                Tab(text: 'ltCreateRoom'.tr),
                Tab(text: 'ltJoinRoom'.tr),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              children: [
                _CreateTab(ctrl: ctrl),
                _JoinTab(ctrl: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create tab ───────────────────────────────────────────────────────────────

class _CreateTab extends StatelessWidget {
  const _CreateTab({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer.withOpacity(0.6),
                  cs.secondaryContainer.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.wifi_tethering_rounded, size: 72, color: cs.primary),
                const SizedBox(height: 16),
                Text('ltCreateTitle'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'ltCreateDesc'.tr,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withOpacity(0.65),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _HowItWorks(steps: [
            _Step(icon: Icons.add_circle_outline_rounded, text: 'ltStep1Create'.tr),
            _Step(icon: Icons.share_outlined, text: 'ltStep2Share'.tr),
            _Step(icon: Icons.sync_rounded, text: 'ltStep3Sync'.tr),
            _Step(icon: Icons.chat_bubble_outline_rounded, text: 'ltStep4Chat'.tr),
          ]),
          const SizedBox(height: 32),
          Obx(() => FilledButton.icon(
                onPressed: ctrl.isConnecting.value ? null : ctrl.createRoom,
                icon: ctrl.isConnecting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_rounded),
                label: Text('ltStartSession'.tr),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Join tab ─────────────────────────────────────────────────────────────────

class _JoinTab extends StatelessWidget {
  const _JoinTab({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.tertiaryContainer.withOpacity(0.6),
                  cs.secondaryContainer.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.group_add_rounded, size: 72, color: cs.tertiary),
                const SizedBox(height: 16),
                Text('ltJoinTitle'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'ltJoinDesc'.tr,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withOpacity(0.65),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: ctrl.codeInputController,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
                color: cs.primary),
            decoration: InputDecoration(
              labelText: 'ltEnterCode'.tr,
              hintText: 'ABCDEF',
              counterText: '',
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.outline.withOpacity(0.3))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => FilledButton.icon(
                onPressed: ctrl.isConnecting.value ? null : ctrl.joinRoom,
                icon: ctrl.isConnecting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.login_rounded),
                label: Text('ltJoinSession'.tr),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// In-Room View — used by BOTH host and guest
// ─────────────────────────────────────────────────────────────────────────────

class _InRoomView extends StatefulWidget {
  const _InRoomView({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  State<_InRoomView> createState() => _InRoomViewState();
}

class _InRoomViewState extends State<_InRoomView> {
  final ScrollController _chatScroll = ScrollController();

  ListenTogetherController get ctrl => widget.ctrl;

  @override
  void dispose() {
    _chatScroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final myRole = ctrl.isHost.value ? 'host' : 'guest';

    // Scroll to bottom whenever a new message arrives.
    ever(ctrl.messages, (_) => _scrollToBottom());

    return Column(
      children: [
        // ── Room code / role header ────────────────────────────────────
        _RoomHeader(ctrl: ctrl),
        const SizedBox(height: 12),

        // ── Now playing card ───────────────────────────────────────────
        ctrl.isHost.value
            ? _HostNowPlayingCard()
            : _GuestNowPlayingCard(ctrl: ctrl),
        const SizedBox(height: 12),

        // ── Chat section ───────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Chat header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        'ltChat'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: cs.primary),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Messages list
                Expanded(
                  child: Obx(() {
                    if (ctrl.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 40,
                                color: cs.onSurface.withOpacity(0.25)),
                            const SizedBox(height: 8),
                            Text(
                              'ltChatEmpty'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: cs.onSurface.withOpacity(0.4)),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _chatScroll,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: ctrl.messages.length,
                      itemBuilder: (_, i) {
                        final msg = ctrl.messages[i];
                        final isMine = msg.senderRole == myRole;
                        return _ChatBubble(
                            msg: msg, isMine: isMine);
                      },
                    );
                  }),
                ),

                // ── Chat input ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl.chatInputController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'ltTypeMessage'.tr,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            filled: true,
                            fillColor:
                                cs.surfaceContainerHighest.withOpacity(0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => ctrl.sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: ctrl.sendMessage,
                        icon: const Icon(Icons.send_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Bottom action row ──────────────────────────────────────────
        Row(
          children: [
            if (!ctrl.isHost.value) ...[
              // Guest: manual sync button
              Expanded(
                child: FilledButton.tonal(
                  onPressed: ctrl.syncNow,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sync_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text('ltSyncNow'.tr),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: ctrl.leaveRoom,
                icon: Icon(
                  ctrl.isHost.value
                      ? Icons.stop_circle_outlined
                      : Icons.logout_rounded,
                  size: 18,
                ),
                label: Text(
                  ctrl.isHost.value ? 'ltEndSession'.tr : 'ltLeaveSession'.tr,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Room header
// ─────────────────────────────────────────────────────────────────────────────

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isHost = ctrl.isHost.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHost
              ? [cs.primaryContainer, cs.secondaryContainer]
              : [cs.tertiaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isHost ? cs.primary : cs.tertiary).withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHost
                      ? Icons.wifi_tethering_rounded
                      : Icons.headphones_rounded,
                  size: 14,
                  color: isHost ? cs.primary : cs.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  isHost ? 'ltHosting'.tr : 'ltGuest'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isHost ? cs.primary : cs.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Room code
          Expanded(
            child: Obx(() => Text(
                  ctrl.roomCode.value ?? '------',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: isHost ? cs.primary : cs.tertiary,
                      ),
                  textAlign: TextAlign.center,
                )),
          ),
          const SizedBox(width: 10),

          // Copy + members
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: ctrl.copyCode,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.copy_rounded, size: 18,
                      color: isHost ? cs.primary : cs.tertiary),
                ),
              ),
              const SizedBox(height: 2),
              Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline_rounded, size: 12),
                      const SizedBox(width: 3),
                      Text('${ctrl.membersOnline.value}',
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Now-playing cards
// ─────────────────────────────────────────────────────────────────────────────

/// Host view — reads live state from PlayerController.
class _HostNowPlayingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<_PlayerObserver>(
      init: _PlayerObserver(),
      builder: (obs) {
        if (obs.songTitle.value.isEmpty) {
          return _InfoTile(
            icon: Icons.music_note_rounded,
            title: 'ltNothingPlaying'.tr,
            subtitle: 'ltNothingPlayingDesc'.tr,
          );
        }
        return _SongProgressCard(
          title: obs.songTitle.value,
          artist: obs.songArtist.value,
          thumbnailUrl: obs.thumbnailUrl.value,
          positionMs: obs.positionMs.value,
          durationMs: obs.durationMs.value,
          isPlaying: obs.isPlaying.value,
        );
      },
    );
  }
}

/// Guest view — reads live estimated state from the controller ticker.
class _GuestNowPlayingCard extends StatelessWidget {
  const _GuestNowPlayingCard({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sync = ctrl.lastSync.value;
      if (sync == null) {
        return _InfoTile(
          icon: Icons.hourglass_empty_rounded,
          title: 'ltWaitingForHost'.tr,
          subtitle: 'ltWaitingDesc'.tr,
        );
      }
      return _SongProgressCard(
        title: sync.songTitle.isNotEmpty ? sync.songTitle : 'ltUnknownSong'.tr,
        artist: sync.songArtist,
        thumbnailUrl: sync.thumbnailUrl,
        positionMs: ctrl.livePositionMs.value,
        durationMs: ctrl.liveDurationMs.value,
        isPlaying: ctrl.liveIsPlaying.value,
      );
    });
  }
}

class _SongProgressCard extends StatelessWidget {
  const _SongProgressCard({
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.positionMs,
    required this.durationMs,
    required this.isPlaying,
  });

  final String title;
  final String artist;
  final String thumbnailUrl;
  final int positionMs;
  final int durationMs;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = durationMs > 0
        ? (positionMs / durationMs).clamp(0.0, 1.0)
        : 0.0;
    final position = Duration(milliseconds: positionMs);
    final total = Duration(milliseconds: durationMs);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const _FallbackThumb(size: 52),
                      )
                    : const _FallbackThumb(size: 52),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (artist.isNotEmpty)
                      Text(artist,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Sync indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPlaying
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 14,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 3),
                    Icon(Icons.sync_rounded, size: 12, color: cs.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.outline.withOpacity(0.2),
              color: cs.primary,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(position),
                  style: Theme.of(context).textTheme.labelSmall),
              Text(_fmt(total),
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat bubble
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.msg, required this.isMine});
  final ChatMessage msg;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = DateTime.fromMillisecondsSinceEpoch(msg.ts);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender label
          Padding(
            padding: const EdgeInsets.only(bottom: 2, left: 4, right: 4),
            child: Text(
              isMine
                  ? 'ltYou'.tr
                  : (msg.senderRole == 'host' ? 'ltHost'.tr : 'ltGuest'.tr),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                  ),
            ),
          ),
          // Bubble
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.tertiaryContainer,
                  child: Icon(Icons.headphones_rounded,
                      size: 14, color: cs.tertiary),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMine ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                          Radius.circular(isMine ? 18 : 4),
                      bottomRight:
                          Radius.circular(isMine ? 4 : 18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: isMine
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          color:
                              isMine ? cs.onPrimary : cs.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: (isMine ? cs.onPrimary : cs.onSurface)
                              .withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(
                    Icons.wifi_tethering_rounded,
                    size: 14,
                    color: cs.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight GetxController that reads PlayerController state reactively.
class _PlayerObserver extends GetxController {
  final songTitle = ''.obs;
  final songArtist = ''.obs;
  final thumbnailUrl = ''.obs;
  final isPlaying = false.obs;
  final positionMs = 0.obs;
  final durationMs = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _sync();
    ever(Get.find<PlayerController>().currentSong, (_) => _sync());
    ever(Get.find<PlayerController>().buttonState, (_) => _sync());
    ever(Get.find<PlayerController>().progressBarStatus, (_) => _sync());
  }

  void _sync() {
    try {
      final p = Get.find<PlayerController>();
      final song = p.currentSong.value;
      songTitle.value = song?.title ?? '';
      songArtist.value = song?.artist ?? '';
      thumbnailUrl.value = song?.artUri?.toString() ?? '';
      isPlaying.value = p.buttonState.value == PlayButtonState.playing;
      positionMs.value = p.progressBarStatus.value.current.inMilliseconds;
      durationMs.value = p.progressBarStatus.value.total.inMilliseconds;
    } catch (_) {}
  }
}

class _FallbackThumb extends StatelessWidget {
  const _FallbackThumb({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.music_note_rounded,
          color: Theme.of(context).colorScheme.primary, size: size * 0.5),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.steps});
  final List<_Step> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'ltHowItWorks'.tr,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
        ...steps.asMap().entries.map((e) {
          final idx = e.key;
          final step = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text('${idx + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Icon(step.icon,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(step.text,
                        style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Step {
  const _Step({required this.icon, required this.text});
  final IconData icon;
  final String text;
}
