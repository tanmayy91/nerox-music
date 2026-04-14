import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/player/components/lyrics_widget.dart';
import '/ui/player/player_controller.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/sleep_timer_bottom_sheet.dart';
import '../../widgets/songinfo_bottom_sheet.dart';

class AlbumArtNLyrics extends StatelessWidget {
  const AlbumArtNLyrics({super.key, required this.playerArtImageSize});
  final double playerArtImageSize;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return Obx(() => playerController.currentSong.value != null
        ? Stack(
            children: [
              GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                    constraints: const BoxConstraints(maxWidth: 500),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10.0)),
                    ),
                    isScrollControlled: true,
                    context:
                        playerController.homeScaffoldkey.currentState!.context,
                    barrierColor: Colors.transparent.withAlpha(100),
                    builder: (context) => SongInfoBottomSheet(
                      playerController.currentSong.value!,
                      calledFromPlayer: true,
                    ),
                  ).whenComplete(() => Get.delete<SongInfoController>());
                },
                onTap: () {
                  playerController.showLyrics();
                },
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (playerController.showLyricsflag.isTrue) return;
                  if (details.primaryVelocity! < 0) {
                    playerController.next();
                  } else if (details.primaryVelocity! > 0) {
                    playerController.prev();
                  }
                },
                // Animated album art with elevation shadow
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ImageWidget(
                      size: playerArtImageSize,
                      song: playerController.currentSong.value!,
                      isPlayerArtImage: true,
                    ),
                  ),
                ),
              ),
              // Lyrics overlay with glassmorphism
              Obx(() => playerController.showLyricsflag.isTrue
                  ? InkWell(
                      onTap: () {
                        playerController.showLyrics();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        height: playerArtImageSize,
                        width: playerArtImageSize,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            LyricsWidget(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: playerArtImageSize / 4)),
                            // Top/bottom gradient fade
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.95),
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.95),
                                    ],
                                    stops: const [0, 0.12, 0.5, 0.88, 1],
                                  ),
                                ),
                              ),
                            ),
                            // "LYRICS" label with pill badge
                            Positioned(
                              top: 14,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.06),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "LYRICS",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              if (playerController.isSleepTimerActive.isTrue)
                SizedBox(
                  width: playerArtImageSize,
                  height: playerArtImageSize,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            border:
                                Border.all(width: 1.2, color: Colors.white.withOpacity(0.3)),
                            color: Colors.black.withOpacity(0.5)),
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              constraints: const BoxConstraints(maxWidth: 500),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0)),
                              ),
                              isScrollControlled: true,
                              context: playerController
                                  .homeScaffoldkey.currentState!.context,
                              barrierColor: Colors.transparent.withAlpha(100),
                              builder: (context) =>
                                  const SleepTimerBottomSheet(),
                            );
                          },
                          icon: Icon(
                            Icons.timer,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          )
        : Container());
  }
}
