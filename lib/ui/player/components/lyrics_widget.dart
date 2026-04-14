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
          ? const Center(
              child: LoadingIndicator(),
            )
          : playerController.lyricsMode.toInt() == 1
              ? _PlainLyricsView(
                  playerController: playerController, padding: padding)
              : _LiveLyricsView(
                  playerController: playerController, padding: padding),
    );
  }
}

/// Apple Music-style plain lyrics view with enhanced styling
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
          () => TextSelectionTheme(
            data: Theme.of(context).textSelectionTheme,
            child: SelectableText(
              playerController.lyrics["plainLyrics"] == "NA"
                  ? "lyricsNotAvailable".tr
                  : playerController.lyrics["plainLyrics"],
              textAlign: TextAlign.center,
              style: playerController.isDesktopLyricsDialogOpen
                  ? Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 18,
                        height: 2.0,
                        fontWeight: FontWeight.w600,
                      )
                  : Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        height: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
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
        return Center(
          child: Text(
            "syncedLyricsNotAvailable".tr,
            style: playerController.isDesktopLyricsDialogOpen
                ? Theme.of(context).textTheme.titleMedium!
                : Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white.withOpacity(0.7)),
          ),
        );
      }
      final lines = _parseLRC(syncedLyrics);
      if (lines.isEmpty) {
        return Center(
          child: Text(
            "syncedLyricsNotAvailable".tr,
            style: playerController.isDesktopLyricsDialogOpen
                ? Theme.of(context).textTheme.titleMedium!
                : Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white.withOpacity(0.7)),
          ),
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

class _LrcLine {
  final int timeMs;
  final String text;
  const _LrcLine({required this.timeMs, required this.text});
}

/// The actual Apple Music-style scrolling lyrics widget
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
                fontSize: isActive ? 30 : 20,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : isPast
                        ? Colors.white.withOpacity(0.35)
                        : Colors.white.withOpacity(0.50),
                height: 1.3,
                letterSpacing: isActive ? -0.5 : -0.3,
                shadows: isActive
                    ? [
                        Shadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                        Shadow(
                          color: const Color(0xFF1DB954).withOpacity(0.2),
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
