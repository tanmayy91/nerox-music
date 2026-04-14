import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '../../models/playlist.dart';
import '../player/player_controller.dart';
import '../screens/Settings/settings_screen_controller.dart';
import 'add_to_playlist.dart';
import 'image_widget.dart';
import 'snackbar.dart';
import 'songinfo_bottom_sheet.dart';

class SongListTile extends StatefulWidget with RemoveSongFromPlaylistMixin {
  const SongListTile(
      {super.key,
      this.onTap,
      required this.song,
      this.playlist,
      this.isPlaylistOrAlbum = false,
      this.thumbReplacementWithIndex = false,
      this.index});
  final Playlist? playlist;
  final MediaItem song;
  final VoidCallback? onTap;
  final bool isPlaylistOrAlbum;

  /// Valid for Album songs
  final bool thumbReplacementWithIndex;
  final int? index;

  @override
  State<SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _showSongInfo(BuildContext context, PlayerController playerController) {
    showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      context: playerController.homeScaffoldkey.currentState!.context,
      barrierColor: Colors.transparent.withAlpha(100),
      builder: (context) => SongInfoBottomSheet(
        widget.song,
        playlist: widget.playlist,
      ),
    ).whenComplete(() => Get.delete<SongInfoController>());
  }

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final duration = widget.song.extras?['length'] as String? ?? '';
    final artist = widget.song.artist ?? '';
    // Build subtitle: "Artist • 3:45" or just "Artist" or just "3:45"
    final subtitle = [artist, if (duration.isNotEmpty) duration]
        .where((s) => s.isNotEmpty)
        .join(' • ');

    return Listener(
        onPointerDown: (PointerDownEvent event) {
          if (event.buttons == kSecondaryMouseButton) {
            _showSongInfo(context, playerController);
          }
        },
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: Slidable(
            enabled: Get.find<SettingsScreenController>()
                .slidableActionEnabled
                .isTrue,
            startActionPane:
                ActionPane(motion: const DrawerMotion(), children: [
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => AddToPlaylist([widget.song]),
                  ).whenComplete(() => Get.delete<AddToPlaylistController>());
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor:
                    Theme.of(context).textTheme.titleMedium!.color,
                icon: Icons.playlist_add_rounded,
              ),
              if (widget.playlist != null && !widget.playlist!.isCloudPlaylist)
                SlidableAction(
                  onPressed: (context) {
                    widget.removeSongFromPlaylist(
                        widget.song, widget.playlist!);
                  },
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor:
                      Theme.of(context).textTheme.titleMedium!.color,
                  icon: Icons.delete_rounded,
                ),
            ]),
            endActionPane:
                ActionPane(motion: const DrawerMotion(), children: [
              SlidableAction(
                onPressed: (context) {
                  playerController.enqueueSong(widget.song).whenComplete(() {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(snackbar(
                        context, "songEnqueueAlert".tr,
                        size: SanckBarSize.MEDIUM));
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor:
                    Theme.of(context).textTheme.titleMedium!.color,
                icon: Icons.merge_rounded,
              ),
              SlidableAction(
                onPressed: (context) {
                  playerController.playNext(widget.song);
                  ScaffoldMessenger.of(context).showSnackBar(snackbar(
                      context,
                      "${"playnextMsg".tr} ${widget.song.title}",
                      size: SanckBarSize.BIG));
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor:
                    Theme.of(context).textTheme.titleMedium!.color,
                icon: Icons.next_plan_rounded,
              ),
            ]),
            child: GestureDetector(
              onTapDown: (_) => _pressCtrl.forward(),
              onTapUp: (_) => _pressCtrl.reverse(),
              onTapCancel: () => _pressCtrl.reverse(),
              child: ListTile(
                onTap: widget.onTap,
                onLongPress: () => _showSongInfo(context, playerController),
                contentPadding:
                    const EdgeInsets.only(top: 0, left: 8, right: 30),
                leading: widget.thumbReplacementWithIndex
                    ? SizedBox(
                        width: 30,
                        height: 56,
                        child: Center(
                          child: Text(
                            "${widget.index}.",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                  Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ImageWidget(
                            size: 56,
                            song: widget.song,
                          ),
                        ),
                      ),
                title: Marquee(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(seconds: 5),
                  id: widget.song.title.hashCode.toString(),
                  child: Text(
                    widget.song.title.length > 50
                        ? widget.song.title.substring(0, 50)
                        : widget.song.title,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 12,
                  ),
                ),
                trailing: SizedBox(
                  width: Get.size.width > 800 ? 80 : 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.isPlaylistOrAlbum)
                        Obx(() =>
                            playerController.currentSong.value?.id ==
                                    widget.song.id
                                ? _AnimatedEqualizer(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .color!)
                                : const SizedBox.shrink()),
                      if (GetPlatform.isDesktop)
                        IconButton(
                            splashRadius: 20,
                            onPressed: () =>
                                _showSongInfo(context, playerController),
                            icon: const Icon(Icons.more_vert_rounded))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

// ---------------------------------------------------------------------------
// Animated equalizer bars (replaces the static Icons.equalizer)
// ---------------------------------------------------------------------------
class _AnimatedEqualizer extends StatefulWidget {
  const _AnimatedEqualizer({required this.color});
  final Color color;

  @override
  State<_AnimatedEqualizer> createState() => _AnimatedEqualizerState();
}

class _AnimatedEqualizerState extends State<_AnimatedEqualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _bars;
  late List<Animation<double>> _anims;

  static const _heights = [0.4, 0.9, 0.6, 0.75];
  static const _delays = [0, 150, 80, 220];

  @override
  void initState() {
    super.initState();
    _bars = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 60),
      )..repeat(reverse: true),
    );
    // Stagger start
    for (var i = 0; i < _bars.length; i++) {
      Future.delayed(Duration(milliseconds: _delays[i]), () {
        if (mounted) _bars[i].repeat(reverse: true);
      });
    }
    _anims = List.generate(
      4,
      (i) => Tween<double>(begin: _heights[i] * 0.3, end: _heights[i])
          .animate(CurvedAnimation(parent: _bars[i], curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    for (final b in _bars) {
      b.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge(_bars),
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            4,
            (i) => Container(
              width: 3,
              height: 20 * _anims[i].value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
