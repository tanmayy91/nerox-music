import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/loader.dart';
import '../player_controller.dart';

class LyricsWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const LyricsWidget({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    return Obx(
      () => playerController.isLyricsLoading.isTrue
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "fetchingLyrics".tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : playerController.lyricsMode.toInt() == 1
              ? _PlainLyricsView(
                  playerController: playerController, padding: padding)
              : _LiveLyricsView(
                  playerController: playerController, padding: padding),
    );
  }
}

/// Refined plain lyrics view with modern styling
class _PlainLyricsView extends StatelessWidget {
  final PlayerController playerController;
  final EdgeInsetsGeometry padding;

  const _PlainLyricsView(
      {required this.playerController, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Obx(
          () {
            final plainLyrics = playerController.lyrics["plainLyrics"];
            if (plainLyrics == "NA") {
              return _LyricsNotAvailableWidget(
                playerController: playerController,
                isDialog: playerController.isDesktopLyricsDialogOpen,
              );
            }
            return TextSelectionTheme(
              data: Theme.of(context).textSelectionTheme,
              child: SelectableText(
                plainLyrics ?? "",
                textAlign: TextAlign.center,
                style: playerController.isDesktopLyricsDialogOpen
                    ? Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 18,
                          height: 2.0,
                          fontWeight: FontWeight.w600,
                        )
                    : Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 18,
                          height: 2.2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Apple Music-style live synced lyrics with line-by-line glow animation
class _LiveLyricsView extends StatelessWidget {
  final PlayerController playerController;
  final EdgeInsetsGeometry padding;

  const _LiveLyricsView(
      {required this.playerController, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final syncedLyrics = playerController.lyrics['synced'].toString();
      if (syncedLyrics.isEmpty) {
        return _LyricsNotAvailableWidget(
          playerController: playerController,
          message: "syncedLyricsNotAvailable".tr,
          isDialog: playerController.isDesktopLyricsDialogOpen,
        );
      }
      final lines = _parseLRC(syncedLyrics);
      if (lines.isEmpty) {
        return _LyricsNotAvailableWidget(
          playerController: playerController,
          message: "syncedLyricsNotAvailable".tr,
          isDialog: playerController.isDesktopLyricsDialogOpen,
        );
      }
      return _AppleMusicLyricsScroller(
        lines: lines,
        playerController: playerController,
        padding: padding,
        isDialog: playerController.isDesktopLyricsDialogOpen,
      );
    });
  }

  /// Parse LRC format into list of (timestamp_ms, text) pairs
  List<_LrcLine> _parseLRC(String lrc) {
    final lines = <_LrcLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    for (final line in lrc.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final min = int.parse(match.group(1)!);
        final sec = int.parse(match.group(2)!);
        final msStr = match.group(3)!;
        final ms = msStr.length == 2
            ? int.parse(msStr) * 10
            : int.parse(msStr);
        final timeMs = (min * 60 + sec) * 1000 + ms;
        final text = match.group(4)!.trim();
        if (text.isNotEmpty) {
          lines.add(_LrcLine(timeMs: timeMs, text: text));
        }
      }
    }
    return lines;
  }
}

/// Widget shown when lyrics are not available, with retry button
class _LyricsNotAvailableWidget extends StatelessWidget {
  final PlayerController playerController;
  final String? message;
  final bool isDialog;

  const _LyricsNotAvailableWidget({
    required this.playerController,
    this.message,
    this.isDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayMessage = message ?? "lyricsNotAvailable".tr;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lyrics_outlined,
            size: 48,
            color: isDialog
                ? Theme.of(context).textTheme.titleMedium!.color?.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            displayMessage,
            style: isDialog
                ? Theme.of(context).textTheme.titleMedium!
                : Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              // Clear cached lyrics and re-fetch
              playerController.lyrics.value = {"synced": "", "plainLyrics": ""};
              playerController.showLyricsflag.value = false;
              playerController.showLyrics();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isDialog
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: isDialog
                        ? Theme.of(context).textTheme.titleMedium!.color
                        : Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "retry".tr,
                    style: TextStyle(
                      color: isDialog
                          ? Theme.of(context).textTheme.titleMedium!.color
                          : Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LrcLine {
  final int timeMs;
  final String text;
  const _LrcLine({required this.timeMs, required this.text});
}

/// Premium scrolling lyrics widget with smooth animations
class _AppleMusicLyricsScroller extends StatefulWidget {
  final List<_LrcLine> lines;
  final PlayerController playerController;
  final EdgeInsetsGeometry padding;
  final bool isDialog;

  const _AppleMusicLyricsScroller({
    required this.lines,
    required this.playerController,
    required this.padding,
    required this.isDialog,
  });

  @override
  State<_AppleMusicLyricsScroller> createState() =>
      _AppleMusicLyricsScrollerState();
}

class _AppleMusicLyricsScrollerState extends State<_AppleMusicLyricsScroller> {
  final ScrollController _scrollController = ScrollController();
  int _lastHighlightedIndex = -1;
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.lines.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _getCurrentLineIndex(int positionMs) {
    int idx = -1;
    for (int i = 0; i < widget.lines.length; i++) {
      if (positionMs >= widget.lines[i].timeMs) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }

  // Estimated height per lyrics line (vertical padding + text height)
  static const double _estimatedLineHeight = 72.0;

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    final viewportHeight = _scrollController.position.viewportDimension;
    final estimatedOffset = (index * _estimatedLineHeight) - (viewportHeight / 3);
    _scrollController.animateTo(
      estimatedOffset.clamp(
          0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final positionMs =
          widget.playerController.progressBarStatus.value.current.inMilliseconds;
      final currentIndex = _getCurrentLineIndex(positionMs);

      // Auto-scroll when highlighted line changes
      if (currentIndex != _lastHighlightedIndex && currentIndex >= 0) {
        _lastHighlightedIndex = currentIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToIndex(currentIndex);
        });
      }

      return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
        itemCount: widget.lines.length + 2, // +2 for top/bottom spacers
        itemBuilder: (context, index) {
          // Top spacer
          if (index == 0) {
            return SizedBox(
                height: MediaQuery.of(context).size.height * 0.15);
          }
          // Bottom spacer
          if (index == widget.lines.length + 1) {
            return SizedBox(
                height: MediaQuery.of(context).size.height * 0.3);
          }

          final lineIndex = index - 1;
          final line = widget.lines[lineIndex];
          final isActive = lineIndex == currentIndex;
          final isPast = lineIndex < currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: isActive ? 28 : 19,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : isPast
                        ? Colors.white.withOpacity(0.25)
                        : Colors.white.withOpacity(0.45),
                height: 1.35,
                letterSpacing: isActive ? -0.5 : -0.3,
                shadows: isActive
                    ? [
                        Shadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 24,
                        ),
                        Shadow(
                          color: Theme.of(context).floatingActionButtonTheme.backgroundColor?.withOpacity(0.15)
                              ?? Colors.purple.withOpacity(0.15),
                          blurRadius: 40,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                line.text,
                key: _itemKeys[lineIndex],
              ),
            ),
          );
        },
      );
    });
  }
}
