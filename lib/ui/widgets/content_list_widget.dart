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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  content.title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              !isHomeContent
                  ? Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          width: 0.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          final scrresController =
                              Get.find<SearchResultScreenController>();
                          scrresController.viewAllCallback(content.title);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Center(
                            child: Text(
                              "viewAll".tr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .color
                                    ?.withOpacity(0.55),
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
          height: 220,
          child: Scrollbar(
            thickness: GetPlatform.isDesktop ? null : 0,
            controller: scrollController,
            child: ListView.separated(
                controller: scrollController,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(
                      width: 12,
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
