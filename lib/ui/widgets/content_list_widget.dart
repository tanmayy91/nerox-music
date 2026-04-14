import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/models/album.dart';
import '../screens/Search/search_result_screen_controller.dart';
import '/ui/widgets/content_list_widget_item.dart';

class ContentListWidget extends StatelessWidget {
  ///ContentListWidget is used to render a section of Content like a list of Albums or Playlists in HomeScreen
  const ContentListWidget(
      {super.key,
      this.content,
      this.isHomeContent = true,
      this.scrollController});

  ///content will be of class Type AlbumContent or PlaylistContent
  final dynamic content;
  final bool isHomeContent;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final isAlbumContent = content is AlbumContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  content.title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              !isHomeContent
                  ? Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .color
                            ?.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          final scrresController =
                              Get.find<SearchResultScreenController>();
                          scrresController.viewAllCallback(content.title);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                            child: Text(
                              "viewAll".tr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .color
                                    ?.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 210,
          child: Scrollbar(
            thickness: GetPlatform.isDesktop ? null : 0,
            controller: scrollController,
            child: ListView.separated(
                controller: scrollController,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(
                      width: 14,
                    ),
                scrollDirection: Axis.horizontal,
                itemCount: isAlbumContent
                    ? content.albumList.length
                    : content.playlistList.length,
                itemBuilder: (_, index) {
                  if (isAlbumContent) {
                    return ContentListItem(content: content.albumList[index]);
                  }
                  return ContentListItem(
                      content: content.playlistList[index]);
                }),
          ),
        ),
      ],
    );
  }
}
