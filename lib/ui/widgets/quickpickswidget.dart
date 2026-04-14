import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/models/quick_picks.dart';
import '../player/player_controller.dart';
import 'image_widget.dart';
import 'songinfo_bottom_sheet.dart';

class QuickPicksWidget extends StatelessWidget {
  const QuickPicksWidget(
      {super.key, required this.content, this.scrollController});
  final QuickPicks content;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  content.title.toLowerCase().removeAllWhitespace.tr,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
              // Play all button
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .color
                      ?.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (content.songList.isNotEmpty) {
                      playerController.pushSongToQueue(content.songList[0]);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                          color: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .color
                              ?.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "play".tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Scrollbar(
              thickness: GetPlatform.isDesktop ? null : 0,
              controller: scrollController,
              child: GridView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: content.songList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: .26 / 1,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (_, item) {
                    return Listener(
                      onPointerDown: (PointerDownEvent event) {
                        if (event.buttons == kSecondaryMouseButton) {
                          _showSongInfo(playerController, content.songList[item]);
                        }
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            playerController
                                .pushSongToQueue(content.songList[item]);
                          },
                          onLongPress: () {
                            _showSongInfo(playerController, content.songList[item]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 3),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ImageWidget(
                                    song: content.songList[item],
                                    size: 52,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        content.songList[item].title,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        "${content.songList[item].artist}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (GetPlatform.isDesktop)
                                  IconButton(
                                      splashRadius: 18,
                                      onPressed: () {
                                        _showSongInfo(playerController, content.songList[item]);
                                      },
                                      icon: const Icon(Icons.more_vert,
                                          size: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  void _showSongInfo(PlayerController playerController, dynamic song) {
    showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      context: playerController
          .homeScaffoldkey.currentState!.context,
      barrierColor: Colors.transparent.withAlpha(100),
      builder: (context) => SongInfoBottomSheet(song),
    ).whenComplete(
        () => Get.delete<SongInfoController>());
  }
}
