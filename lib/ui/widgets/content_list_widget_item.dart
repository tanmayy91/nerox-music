import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigator.dart';
import 'image_widget.dart';

class ContentListItem extends StatelessWidget {
  const ContentListItem(
      {super.key, required this.content, this.isLibraryItem = false});

  ///content will be of Type class Album or Playlist
  final dynamic content;
  final bool isLibraryItem;

  @override
  Widget build(BuildContext context) {
    final isAlbum = content.runtimeType.toString() == "Album";
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (isAlbum) {
          Get.toNamed(ScreenNavigationSetup.albumScreen,
              id: ScreenNavigationSetup.id, arguments:(content, content.browseId));
          return;
        }
        Get.toNamed(ScreenNavigationSetup.playlistScreen,
            id: ScreenNavigationSetup.id,
            arguments: [content, content.playlistId]);
      },
      child: Container(
        width: 140,
        height: 195,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isAlbum
                ? ImageWidget(
                    size: 132,
                    album: content,
                  )
                : content.isCloudPlaylist ||
                        !(content.playlistId == 'LIBRP' ||
                            content.playlistId == 'LIBFAV' ||
                            content.playlistId == 'SongsCache' ||
                            content.playlistId == 'SongDownloads')
                    ? SizedBox.square(
                        dimension: 132,
                        child: Stack(
                          children: [
                            ImageWidget(
                              size: 132,
                              playlist: content,
                            ),
                            if (content.isPipedPlaylist)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.85),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "P",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 12),
                                    )),
                                  ),
                                ),
                              ),
                            if (!content.isCloudPlaylist)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.85),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "L",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 12),
                                    )),
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    : Container(
                        height: 132,
                        width: 132,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                            child: Icon(
                          content.playlistId == 'LIBRP'
                              ? Icons.history_rounded
                              : content.playlistId == 'LIBFAV'
                                  ? Icons.favorite_rounded
                                  : content.playlistId == 'SongsCache'
                                      ? Icons.flight_rounded
                                      : Icons.download_rounded,
                          color: Colors.white,
                          size: 36,
                        ))),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAlbum
                        ? isLibraryItem
                            ? ""
                            : "${content.artists[0]['name'] ?? ""} | ${content.year ?? ""}"
                        : isLibraryItem
                            ? ""
                            : content.description ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
