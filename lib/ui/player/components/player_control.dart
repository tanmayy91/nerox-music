import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '/ui/player/components/animated_play_button.dart';
import '../player_controller.dart';

class PlayerControlWidget extends StatelessWidget {
  const PlayerControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.transparent
                      ],
                    ).createShader(
                        Rect.fromLTWH(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Marquee(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(seconds: 10),
                          id: "${playerController.currentSong.value}_title",
                          child: Text(
                            playerController.currentSong.value != null
                                ? playerController.currentSong.value!.title
                                : "NA",
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.labelMedium!,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Marquee(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(seconds: 10),
                          id: "${playerController.currentSong.value}_subtitle",
                          child: Text(
                            playerController.currentSong.value != null
                                ? playerController.currentSong.value!.artist!
                                : "NA",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ),
              // Heart / Favourite button with pop animation
              _FavouriteButton(playerController: playerController),
            ],
          ),
          const SizedBox(height: 20),
          GetX<PlayerController>(builder: (controller) {
            return ProgressBar(
              thumbRadius: 7,
              barHeight: 4.5,
              baseBarColor: Theme.of(context).sliderTheme.inactiveTrackColor,
              bufferedBarColor:
                  Theme.of(context).sliderTheme.valueIndicatorColor,
              progressBarColor: Theme.of(context).sliderTheme.activeTrackColor,
              thumbColor: Theme.of(context).sliderTheme.thumbColor,
              timeLabelTextStyle: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 14),
              progress: controller.progressBarStatus.value.current,
              total: controller.progressBarStatus.value.total,
              buffered: controller.progressBarStatus.value.buffered,
              onSeek: controller.seek,
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Shuffle — spins on each toggle
              _AnimatedToggleIconButton(
                icon: Ionicons.shuffle,
                isActive: playerController.isShuffleModeEnabled,
                onTap: playerController.toggleShuffleMode,
                spinOnToggle: true,
              ),
              _previousButton(playerController, context),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                    radius: 36,
                    child: AnimatedPlayButton(key: Key("playButton"))),
              ),
              _nextButton(playerController, context),
              // Loop — bounces on each toggle
              _AnimatedToggleIconButton(
                icon: Icons.all_inclusive,
                isActive: playerController.isLoopModeEnabled,
                onTap: playerController.toggleLoopMode,
                spinOnToggle: false,
              ),
            ],
          ),
        ]);
  }

  Widget _previousButton(
      PlayerController playerController, BuildContext context) {
    return _ScaleOnTapButton(
      onTap: playerController.prev,
      child: Icon(
        Icons.skip_previous_rounded,
        color: Theme.of(context).textTheme.titleMedium!.color,
        size: 38,
      ),
    );
  }
}

Widget _nextButton(PlayerController playerController, BuildContext context) {
  return Obx(() {
    final isLastSong = playerController.currentQueue.isEmpty ||
        (!(playerController.isShuffleModeEnabled.isTrue ||
                playerController.isQueueLoopModeEnabled.isTrue) &&
            (playerController.currentQueue.last.id ==
                playerController.currentSong.value?.id));
    return _ScaleOnTapButton(
      onTap: isLastSong ? null : playerController.next,
      child: Icon(
        Icons.skip_next_rounded,
        color: isLastSong
            ? Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.15)
            : Theme.of(context).textTheme.titleMedium!.color,
        size: 38,
      ),
    );
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// An icon button that shrinks briefly on tap and rotates/bounces on toggle.
class _AnimatedToggleIconButton extends StatefulWidget {
  const _AnimatedToggleIconButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.spinOnToggle = false,
  });

  final IconData icon;
  final RxBool isActive;
  final VoidCallback onTap;
  final bool spinOnToggle;

  @override
  State<_AnimatedToggleIconButton> createState() =>
      _AnimatedToggleIconButtonState();
}

class _AnimatedToggleIconButtonState extends State<_AnimatedToggleIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotation;
  late Animation<double> _scale;
  bool _lastActive = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _rotation = Tween<double>(begin: 0, end: widget.spinOnToggle ? 1 : 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.90), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = widget.isActive.value;
      if (active != _lastActive) _lastActive = active;

      return GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.rotate(
            angle: _rotation.value * 2 * 3.14159,
            child: Transform.scale(scale: _scale.value, child: child),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: active ? 1.0 : 0.28,
            child: Icon(
              widget.icon,
              color: Theme.of(context).textTheme.titleLarge!.color,
              size: 24,
            ),
          ),
        ),
      );
    });
  }
}

/// Scales down slightly on tap for tactile feel.
class _ScaleOnTapButton extends StatefulWidget {
  const _ScaleOnTapButton({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_ScaleOnTapButton> createState() => _ScaleOnTapButtonState();
}

class _ScaleOnTapButtonState extends State<_ScaleOnTapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.78)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Heart button with a springy pop animation when favourited.
class _FavouriteButton extends StatefulWidget {
  const _FavouriteButton({required this.playerController});
  final PlayerController playerController;

  @override
  State<_FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<_FavouriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: GestureDetector(
        onTap: () {
          widget.playerController.toggleFavourite();
          _ctrl.forward(from: 0);
        },
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: Obx(() => Icon(
                widget.playerController.isCurrentSongFav.isFalse
                    ? Icons.favorite_border_rounded
                    : Icons.favorite_rounded,
                color: widget.playerController.isCurrentSongFav.isTrue
                    ? const Color(0xFFFF5C8D)
                    : Theme.of(context).textTheme.titleMedium!.color,
                size: 26,
              )),
        ),
      ),
    );
  }
}
