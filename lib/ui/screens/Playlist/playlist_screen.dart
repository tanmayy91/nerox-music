import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '/models/playling_from.dart';
import '/models/thumbnail.dart';
import '/ui/widgets/playlist_album_scroll_behaviour.dart';
import '../../navigator.dart';
import '../../player/player_controller.dart';
import '../../widgets/create_playlist_dialog.dart';
import '../../widgets/loader.dart';
import '../../widgets/playlist_collage_widget.dart';
import '../../widgets/playlist_export_dialog.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/song_list_tile.dart';
import '../../widgets/songinfo_bottom_sheet.dart';
import '../../widgets/sort_widget.dart';
import '../Library/library_controller.dart';
import 'playlist_screen_controller.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = key.hashCode.toString();
    final playlistController =
        (Get.isRegistered<PlaylistScreenController>(tag: tag))
            ? Get.find<PlaylistScreenController>(tag: tag)
            : Get.put(PlaylistScreenController(), tag: tag);
    final size = MediaQuery.of(context).size;
    final playerController = Get.find<PlayerController>();
    final landscape = size.width > size.height;
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          final scrollOffset = scrollInfo.metrics.pixels;

          if (landscape) {
            playlistController.scrollOffset.value = 0;
          } else {
            playlistController.scrollOffset.value = scrollOffset;
          }
          if (scrollOffset > 270 || (landscape && scrollOffset > 215)) {
            playlistController.appBarTitleVisible.value = true;
          } else {
            playlistController.appBarTitleVisible.value = false;
          }
          return true;
        },
        child: Stack(
          children: [
            Obx(
              () => playlistController.isContentFetched.isTrue
                  ? Positioned(
                      top: landscape
                          ? 0
                          : -.25 * playlistController.scrollOffset.value,
                      right: landscape ? 0 : null,
                      child: Obx(() {
                        final opacityValue = 1 -
                            playlistController.scrollOffset.value /
                                (size.width - 100);
                        // Collect first 4 unique art URLs from loaded songs
                        final artUrls = playlistController.songList
                            .map((s) => s.artUri?.toString() ?? '')
                            .where((u) => u.isNotEmpty)
                            .toSet()
                            .take(4)
                            .toList();
                        final useCollage = artUrls.length >= 4;
                        return Opacity(
                          opacity: opacityValue < 0 ||
                                  playlistController.isSearchingOn.isTrue &&
                                      !landscape
                              ? 0
                              : opacityValue,
                          child: DecoratedBox(
                            position: DecorationPosition.foreground,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).canvasColor,
                                  spreadRadius: 200,
                                  blurRadius: 100,
                                  offset: Offset(-size.height, 0),
                                ),
                                BoxShadow(
                                  color: Theme.of(context).canvasColor,
                                  spreadRadius: 200,
                                  blurRadius: 100,
                                  offset: Offset(
                                      0,
                                      landscape
                                          ? size.height
                                          : size.width + 80),
                                )
                              ],
                            ),
                            child: useCollage
                                ? PlaylistCollageWidget(
                                    imageUrls: artUrls,
                                    size: landscape ? size.height : size.width,
                                    borderRadius: 0,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: Thumbnail(playlistController
                                            .playlist.value.thumbnailUrl)
                                        .extraHigh,
                                    fit: landscape
                                        ? BoxFit.fitHeight
                                        : BoxFit.cover,
                                    width:
                                        landscape ? null : size.width,
                                    height: landscape
                                        ? size.height
                                        : size.width,
                                  ),
                          ),
                        );
                      }))
                  : SizedBox(
                      height: size.width,
                      width: size.width,
                    ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 10,
                      right: 10),
                  height: 80,
                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: IconButton(
                            tooltip: "back".tr,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back_ios)),
                        ),
                        Expanded(
                          child: Obx(
                            () => Marquee(
                              delay: const Duration(milliseconds: 300),
                              duration: const Duration(seconds: 5),
                              id: "${playlistController.playlist.value.title.hashCode.toString()}_appbar",
                              child: Text(
                                playlistController.appBarTitleVisible.isTrue
                                    ? playlistController.playlist.value.title
                                    : "",
                                maxLines: 1,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                        ),
                        if (!playlistController
                                .playlist.value.isCloudPlaylist &&
                            playlistController.isDefaultPlaylist.isFalse)
                          SizedBox(
                            width: 50,
                            child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    constraints:
                                        const BoxConstraints(maxWidth: 500),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10.0)),
                                    ),
                                    context: Get.find<PlayerController>()
                                        .homeScaffoldkey
                                        .currentState!
                                        .context,
                                    barrierColor:
                                        Colors.transparent.withAlpha(100),
                                    builder: (context) => SizedBox(
                                      height: 140,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.edit),
                                            title: Text("renamePlaylist".tr),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    CreateNRenamePlaylistPopup(
                                                        renamePlaylist: true,
                                                        playlist:
                                                            playlistController
                                                                .playlist
                                                                .value),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete),
                                            title: Text("removePlaylist".tr),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              playlistController
                                                  .addNremoveFromLibrary(
                                                      playlistController
                                                          .playlist.value,
                                                      add: false)
                                                  .then((value) {
                                                Get.nestedKey(
                                                        ScreenNavigationSetup
                                                            .id)!
                                                    .currentState!
                                                    .pop();
                                                ScaffoldMessenger.of(
                                                        Get.context!)
                                                    .showSnackBar(snackbar(
                                                        Get.context!,
                                                        value
                                                            ? "playlistRemovedAlert"
                                                                .tr
                                                            : "operationFailed"
                                                                .tr,
                                                        size: SanckBarSize
                                                            .MEDIUM));
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.more_vert)),
                          )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 800,
                      ),
                      child: Obx(
                        () => ScrollConfiguration(
                          behavior: PlaylistAlbumScrollBehaviour(),
                          child: ListView.builder(
                            addRepaintBoundaries: false,
                            padding: EdgeInsets.only(
                              top: playlistController.isSearchingOn.isTrue
                                  ? 0
                                  : landscape
                                      ? 150
                                      : 200,
                              bottom: 200,
                            ),
                            itemCount: playlistController.songList.isEmpty ||
                                    playlistController.isContentFetched.isFalse
                                ? 4
                                : playlistController.songList.length + 3,
                            itemBuilder: (_, index) {
                              if (index == 0) {
                                // ── Action row ──────────────────────────────
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Secondary icon row
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            // Bookmark
                                            Obx(() => (playlistController.playlist.value.isPipedPlaylist ||
                                                    !playlistController.playlist.value.isCloudPlaylist)
                                                ? const SizedBox.shrink()
                                                : _PlaylistIconChip(
                                                    icon: playlistController.isAddedToLibrary.isFalse
                                                        ? Icons.bookmark_add_rounded
                                                        : Icons.bookmark_added_rounded,
                                                    tooltip: playlistController.isAddedToLibrary.isFalse
                                                        ? "addToLibrary".tr
                                                        : "removeFromLibrary".tr,
                                                    onTap: () {
                                                      final add = playlistController.isAddedToLibrary.isFalse;
                                                      playlistController
                                                          .addNremoveFromLibrary(playlistController.playlist.value, add: add)
                                                          .then((value) {
                                                        if (!context.mounted) return;
                                                        ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                                            context,
                                                            value
                                                                ? add
                                                                    ? "playlistBookmarkAddAlert".tr
                                                                    : "listBookmarkRemoveAlert".tr
                                                                : "operationFailed".tr,
                                                            size: SanckBarSize.MEDIUM));
                                                      });
                                                    },
                                                  )),
                                            // Enqueue
                                            _PlaylistIconChip(
                                              icon: Icons.merge_rounded,
                                              tooltip: "enqueueSongs".tr,
                                              onTap: () {
                                                Get.find<PlayerController>()
                                                    .enqueueSongList(playlistController.songList.toList())
                                                    .whenComplete(() {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                                        context, "songEnqueueAlert".tr,
                                                        size: SanckBarSize.MEDIUM));
                                                  }
                                                });
                                              },
                                            ),
                                            // Cloud Sync
                                            if (playlistController.isAddedToLibrary.isTrue)
                                              _PlaylistIconChip(
                                                icon: Icons.cloud_sync_rounded,
                                                tooltip: "syncPlaylistSongs".tr,
                                                onTap: playlistController.syncPlaylistSongs,
                                              ),
                                            // Blacklist (Piped)
                                            if (playlistController.playlist.value.isPipedPlaylist)
                                              _PlaylistIconChip(
                                                icon: Icons.block_rounded,
                                                tooltip: "blacklistPipedPlaylist".tr,
                                                onTap: () {
                                                  Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                                                  Get.find<LibraryPlaylistsController>()
                                                      .blacklistPipedPlaylist(playlistController.playlist.value);
                                                  if (Get.context != null) {
                                                    ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
                                                        Get.context!, "playlistBlacklistAlert".tr,
                                                        size: SanckBarSize.MEDIUM));
                                                  }
                                                },
                                              ),
                                            // Share
                                            if (playlistController.playlist.value.isCloudPlaylist)
                                              _PlaylistIconChip(
                                                icon: Icons.share_rounded,
                                                tooltip: "sharePlaylist".tr,
                                                onTap: () {
                                                  final c = playlistController.playlist.value;
                                                  if (c.isPipedPlaylist) {
                                                    Share.share("https://piped.video/playlist?list=${c.playlistId}");
                                                  } else {
                                                    final prefix = c.playlistId.substring(0, 2) == "VL";
                                                    Share.share(
                                                        "https://youtube.com/playlist?list=${prefix ? c.playlistId.substring(2) : c.playlistId}");
                                                  }
                                                },
                                              ),
                                            // Export
                                            _PlaylistIconChip(
                                              icon: Icons.file_upload_rounded,
                                              tooltip: "exportPlaylist".tr,
                                              onTap: () => showDialog(
                                                context: context,
                                                builder: (dialogContext) => PlaylistExportDialog(
                                                    controller: playlistController, parentContext: context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // ── Pill buttons ──────────────────────
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _PillButton(
                                              label: "play".tr,
                                              icon: Icons.play_arrow_rounded,
                                              filled: true,
                                              onTap: () => playerController.playPlayListSong(
                                                List<MediaItem>.from(playlistController.songList),
                                                0,
                                                playfrom: PlaylingFrom(
                                                    name: playlistController.playlist.value.title,
                                                    type: PlaylingFromType.PLAYLIST),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _PillButton(
                                              label: "shuffle".tr,
                                              icon: Icons.shuffle_rounded,
                                              filled: false,
                                              onTap: () {
                                                final songs = List<MediaItem>.from(playlistController.songList);
                                                songs.shuffle();
                                                playerController.playPlayListSong(
                                                  songs, 0,
                                                  playfrom: PlaylingFrom(
                                                      name: playlistController.playlist.value.title,
                                                      type: PlaylingFromType.PLAYLIST),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else if (index == 1) {
                                final title =
                                    playlistController.playlist.value.title;
                                final description = playlistController
                                    .playlist.value.description;

                                return AnimatedBuilder(
                                  animation:
                                      playlistController.animationController,
                                  builder: (context, child) {
                                    return SizedBox(
                                      height: playlistController
                                          .heightAnimation.value,
                                      child: Transform.scale(
                                        scale: playlistController
                                            .scaleAnimation.value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, bottom: 10, right: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Marquee(
                                          delay:
                                              const Duration(milliseconds: 300),
                                          duration: const Duration(seconds: 5),
                                          id: title.hashCode.toString(),
                                          child: Text(
                                            title.length > 50
                                                ? title.substring(0, 50)
                                                : title,
                                            maxLines: 1,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.5,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Row(
                                            children: [
                                              if (playlistController.songList.isNotEmpty)
                                                Text(
                                                  "${playlistController.songList.length} ${"songs".tr}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(fontSize: 13),
                                                ),
                                              if (description != null && description.isNotEmpty) ...[
                                                if (playlistController.songList.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    child: Text(
                                                      "•",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall,
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Marquee(
                                                    delay: const Duration(
                                                        milliseconds: 300),
                                                    duration:
                                                        const Duration(seconds: 5),
                                                    id: description.hashCode.toString(),
                                                    child: Text(
                                                      description,
                                                      maxLines: 1,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(fontSize: 13),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (description == null || description.isEmpty)
                                                Expanded(
                                                  child: Text(
                                                    "playlist".tr,
                                                    maxLines: 1,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(fontSize: 13),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (index == 2) {
                                return SizedBox(
                                    height:
                                        playlistController.isSearchingOn.isTrue
                                            ? 60
                                            : 40,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 10),
                                      child: Obx(
                                        () => SortWidget(
                                          tag: playlistController
                                              .playlist.value.playlistId,
                                          screenController: playlistController,
                                          isSearchFeatureRequired: true,
                                          isPlaylistRearrageFeatureRequired: !playlistController
                                                  .playlist
                                                  .value
                                                  .isCloudPlaylist &&
                                              playlistController.playlist.value
                                                      .playlistId !=
                                                  "LIBRP" &&
                                              playlistController.playlist.value
                                                      .playlistId !=
                                                  "SongDownloads" &&
                                              playlistController.playlist.value
                                                      .playlistId !=
                                                  "SongsCache",
                                          isSongDeletetioFeatureRequired:
                                              !playlistController.playlist.value
                                                  .isCloudPlaylist,
                                          itemCountTitle:
                                              "${playlistController.songList.length}",
                                          itemIcon: Icons.music_note,
                                          titleLeftPadding: 9,
                                          requiredSortTypes:
                                              buildSortTypeSet(false, true),
                                          onSort: playlistController.onSort,
                                          onSearch: playlistController.onSearch,
                                          onSearchClose:
                                              playlistController.onSearchClose,
                                          onSearchStart:
                                              playlistController.onSearchStart,
                                          startAdditionalOperation:
                                              playlistController
                                                  .startAdditionalOperation,
                                          selectAll:
                                              playlistController.selectAll,
                                          performAdditionalOperation:
                                              playlistController
                                                  .performAdditionalOperation,
                                          cancelAdditionalOperation:
                                              playlistController
                                                  .cancelAdditionalOperation,
                                        ),
                                      ),
                                    ));
                              } else if (playlistController
                                      .isContentFetched.isFalse ||
                                  playlistController.songList.isEmpty) {
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: playlistController
                                            .isContentFetched.isFalse
                                        ? const LoadingIndicator()
                                        : Text(
                                            "emptyPlaylist".tr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                  ),
                                );
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 20.0, right: 5),
                                child: SongListTile(
                                  onTap: () {
                                    playerController.playPlayListSong(
                                        List<MediaItem>.from(
                                            playlistController.songList),
                                        index - 3,
                                        playfrom: PlaylingFrom(
                                            name: playlistController
                                                .playlist.value.title,
                                            type: PlaylingFromType.PLAYLIST));
                                  },
                                  song: playlistController.songList[index - 3],
                                  isPlaylistOrAlbum: true,
                                  playlist: playlistController.playlist.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future openBottomSheet(BuildContext context, MediaItem song) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      isScrollControlled: true,
      context: context,
      barrierColor: Colors.transparent.withAlpha(100),
      builder: (context) => SongInfoBottomSheet(song),
    ).whenComplete(() => Get.delete<SongInfoController>());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Small rounded icon chip used in the secondary action row.
class _PlaylistIconChip extends StatelessWidget {
  const _PlaylistIconChip({
    required this.icon,
    this.tooltip = '',
    this.onTap,
    this.child,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  /// Overrides the icon with a custom widget (e.g. progress indicator).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .color!
                  .withOpacity(0.08),
            ),
            child: Center(
              child: child ??
                  Icon(icon,
                      size: 18,
                      color: onTap == null
                          ? Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .color!
                              .withOpacity(0.35)
                          : Theme.of(context).textTheme.titleMedium!.color),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large pill-shaped Play or Shuffle button matching the reference design.
class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.filled
        ? Theme.of(context).textTheme.titleLarge!.color!
        : Colors.transparent;
    final fgColor = widget.filled
        ? Theme.of(context).canvasColor
        : Theme.of(context).textTheme.titleLarge!.color!;
    final border = widget.filled
        ? null
        : Border.all(
            color: Theme.of(context)
                .textTheme
                .titleLarge!
                .color!
                .withOpacity(0.35),
            width: 1.5);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: fgColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
