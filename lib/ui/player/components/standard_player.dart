import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/songinfo_bottom_sheet.dart';
import '../player_controller.dart';
import 'albumart_lyrics.dart';
import 'backgroud_image.dart';
import 'lyrics_switch.dart';
import 'player_control.dart';

/// Standard player widget – V3 immersive design
///
/// Deep blur with rich color-aware gradients for a premium feel
class StandardPlayer extends StatelessWidget {
  const StandardPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();

    double playerArtImageSize = size.width - 60;
    final spaceAvailableForArtImage =
        size.height - (70 + Get.mediaQuery.padding.bottom + 330);
    playerArtImageSize = playerArtImageSize > spaceAvailableForArtImage
        ? spaceAvailableForArtImage
        : playerArtImageSize;
    return Stack(
      children: [
        /// Background album art
        BackgroudImage(
          key: Key("${playerController.currentSong.value?.id}_background"),
          cacheHeight: 200,
        ),

        /// Deep immersive blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
          child: Stack(
            children: [
              /// Primary gradient: deep fade from album color to black
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.3, 0.7, 1.0],
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.75),
                        Theme.of(context).primaryColor.withOpacity(0.50),
                        Colors.black.withOpacity(0.80),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),

              /// Ambient glow from top-center
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.7),
                      radius: 1.4,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.20),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              /// Subtle side vignette for depth
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              /// Bottom gradient
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 70 + Get.mediaQuery.padding.bottom + 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.95),
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.25),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0, 0.35, 0.7, 1],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Player content
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: (context.isLandscape)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: size.width * .45,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: AlbumArtNLyrics(
                              playerArtImageSize: size.width * .29,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: size.width * .48,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10.0,
                              right: 10,
                              bottom: Get.mediaQuery.padding.bottom),
                          child: const PlayerControlWidget(),
                        ))
                  ],
                )
              : Column(
                  children: [
                    Obx(
                      () => AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        height: playerController.showLyricsflag.value
                            ? (size.height < 750 ? 55 : 85)
                            : (size.height < 750 ? 105 : 135),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LyricsSwitch(),
                        ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: AlbumArtNLyrics(
                                playerArtImageSize: playerArtImageSize)),
                      ],
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 80 + Get.mediaQuery.padding.bottom),
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: const PlayerControlWidget()),
                    )
                  ],
                ),
        ),

        /// Top bar: minimize, playing from, more
        if (!(context.isLandscape && GetPlatform.isMobile))
          Padding(
            padding: EdgeInsets.only(
                top: Get.mediaQuery.padding.top + 20, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Minimize button with subtle glass background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 28,
                    ),
                    onPressed: playerController.playerPanelController.close,
                  ),
                ),

                /// Playing from info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                    child: Obx(
                      () => Column(
                        children: [
                          Text(playerController.playinfrom.value.typeString,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.40),
                                  letterSpacing: 1.0,
                              )),
                          const SizedBox(height: 3),
                          Obx(
                            () => Text(
                              "\"${playerController.playinfrom.value.nameString}\"",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                /// More button with glass background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      size: 25,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        constraints: const BoxConstraints(maxWidth: 500),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24.0)),
                        ),
                        isScrollControlled: true,
                        context: playerController
                            .homeScaffoldkey.currentState!.context,
                        barrierColor: Colors.transparent.withAlpha(100),
                        builder: (context) => SongInfoBottomSheet(
                          playerController.currentSong.value!,
                          calledFromPlayer: true,
                        ),
                      ).whenComplete(() => Get.delete<SongInfoController>());
                    },
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}
