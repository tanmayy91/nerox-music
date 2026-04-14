import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '/ui/player/components/gesture_player.dart';
import '/ui/player/components/standard_player.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '../../utils/helper.dart';
import '../widgets/snackbar.dart';
import '../widgets/up_next_queue.dart';
import '/ui/player/player_controller.dart';
import '../widgets/sliding_up_panel.dart';
import 'components/lyrics_widget.dart';

/// Player screen
/// Contains the player ui
///
/// Player ui can be standard player or gesture player
class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final settingsScreenController = Get.find<SettingsScreenController>();
    return Scaffold(
      /// SlidingUpPanel is used to create a panel that can slide up and down
      /// Swipe up now opens LYRICS panel (not queue)
      body: Obx(
        () => SlidingUpPanel(
          boxShadow: const [],
          minHeight: settingsScreenController.playerUi.value == 0
              ? 65 + Get.mediaQuery.padding.bottom
              : 0,
          maxHeight: size.height,
          isDraggable: !GetPlatform.isDesktop,
          controller: GetPlatform.isDesktop
              ? null
              : playerController.queuePanelController,

          /// Collapsed header — swipe up indicator for lyrics
          collapsed: InkWell(
            onTap: () {
              if (GetPlatform.isDesktop) {
                playerController.homeScaffoldkey.currentState!.openEndDrawer();
              } else {
                playerController.queuePanelController.open();
              }
            },
            child: Container(
                color: Theme.of(context).primaryColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: 65,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lyrics_outlined,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .color
                                  ?.withOpacity(0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "LYRICS",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .color
                                    ?.withOpacity(0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .color
                                  ?.withOpacity(0.5),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),

          /// Panel — full-screen lyrics view with queue access button
          panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
            playerController.scrollController = sc;
            return _LyricsPanel(
              playerController: playerController,
              onReorderStart: onReorderStart,
              onReorderEnd: onReorderEnd,
            );
          },

          /// show player ui based on selected player ui in settings
          /// Gesture player is only applicable for mobile
          body: settingsScreenController.playerUi.value == 0
              ? const StandardPlayer()
              : const GesturePlayer(),
        ),
      ),
    );
  }
}

/// Full-screen lyrics panel that opens on swipe up
class _LyricsPanel extends StatelessWidget {
  final PlayerController playerController;
  final void Function(int) onReorderStart;
  final void Function(int) onReorderEnd;

  const _LyricsPanel({
    required this.playerController,
    required this.onReorderStart,
    required this.onReorderEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Column(
        children: [
          // Top bar with drag handle, title, and queue button
          SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      IconButton(
                        onPressed: () {
                          playerController.queuePanelController.close();
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withOpacity(0.7),
                          size: 28,
                        ),
                      ),
                      // "LYRICS" title
                      Text(
                        "LYRICS",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                      // Queue button
                      IconButton(
                        onPressed: () {
                          playerController.queuePanelController.close();
                          if (GetPlatform.isDesktop) {
                            playerController.homeScaffoldkey.currentState!
                                .openEndDrawer();
                          } else {
                            _showQueueBottomSheet(context);
                          }
                        },
                        icon: Icon(
                          Icons.queue_music_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Song info
          Obx(() {
            final song = playerController.currentSong.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    song?.title ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song?.artist ?? "",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Lyrics content (auto-fetches if needed)
          Expanded(
            child: Obx(() {
              // Auto-trigger lyrics loading when panel opens
              final synced = playerController.lyrics["synced"];
              final plain = playerController.lyrics["plainLyrics"];
              if ((synced == null || (synced is String && synced.isEmpty)) &&
                  (plain == null || (plain is String && plain.isEmpty)) &&
                  playerController.isLyricsLoading.isFalse &&
                  playerController.currentSong.value != null) {
                // Trigger lyrics fetch if not already loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!playerController.showLyricsflag.value) {
                    playerController.showLyrics();
                  }
                });
              }
              return const LyricsWidget(
                padding: EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
              );
            }),
          ),

          // Bottom bar with lyrics mode toggle and queue count
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(
                    top: 12,
                    bottom: 10 + Get.mediaQuery.padding.bottom,
                    left: 16,
                    right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Song count in queue
                    Obx(
                      () => Text(
                        "${playerController.currentQueue.length} ${"songs".tr}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Synced/Plain toggle
                    _LyricsModeToggle(playerController: playerController),

                    // View queue button
                    InkWell(
                      onTap: () {
                        playerController.queuePanelController.close();
                        _showQueueBottomSheet(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.queue_music,
                                color: Colors.white.withOpacity(0.8),
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "Queue",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQueueBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: playerController.homeScaffoldkey.currentState!.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor ??
                  const Color(0xFF141414),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "UP NEXT",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      Row(
                        children: [
                          // Queue loop
                          InkWell(
                            onTap: playerController.toggleQueueLoopMode,
                            child: Obx(
                              () => Container(
                                height: 30,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: playerController
                                          .isQueueLoopModeEnabled.isFalse
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child:
                                    Center(child: Text("queueLoop".tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Shuffle
                          InkWell(
                            onTap: () {
                              if (playerController
                                  .isShuffleModeEnabled.isTrue) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(context,
                                        "queueShufflingDeniedMsg".tr,
                                        size: SanckBarSize.BIG));
                                return;
                              }
                              playerController.shuffleQueue();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.shuffle,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Clear
                          InkWell(
                            onTap: playerController.clearQueue,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.playlist_remove,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: UpNextQueue(
                    onReorderEnd: (_) {},
                    onReorderStart: (_) {},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Compact lyrics mode toggle (synced / plain)
class _LyricsModeToggle extends StatelessWidget {
  final PlayerController playerController;
  const _LyricsModeToggle({required this.playerController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = playerController.lyricsMode.value;
      return Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _modeButton(
                "synced".tr, 0, mode == 0, context),
            _modeButton(
                "plain".tr, 1, mode == 1, context),
          ],
        ),
      );
    });
  }

  Widget _modeButton(
      String label, int modeVal, bool isActive, BuildContext context) {
    return InkWell(
      onTap: () => playerController.changeLyricsMode(modeVal),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
