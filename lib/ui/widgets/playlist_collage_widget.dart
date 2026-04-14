import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a 2×2 grid of album art when 4+ URLs are supplied,
/// otherwise falls back to a single image.
class PlaylistCollageWidget extends StatelessWidget {
  const PlaylistCollageWidget({
    super.key,
    required this.imageUrls,
    required this.size,
    this.borderRadius = 16.0,
  });

  final List<String> imageUrls;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.take(4).toList();
    final showCollage = urls.length >= 4;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: size,
        width: size,
        child: showCollage
            ? Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _tile(urls[0]),
                        const SizedBox(width: 2),
                        _tile(urls[1]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Row(
                      children: [
                        _tile(urls[2]),
                        const SizedBox(width: 2),
                        _tile(urls[3]),
                      ],
                    ),
                  ),
                ],
              )
            : _tile(urls.isNotEmpty ? urls[0] : ''),
      ),
    );
  }

  Widget _tile(String url) => Expanded(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (context, __, ___) => Container(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      );
}
