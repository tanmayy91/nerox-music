import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'basic_container.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
        enabled: true,
        direction: ShimmerDirection.ltr,
        child: Column(
          children: [_discoverWidget(), _contentWidget(), _contentWidget()],
        ));
  }

  Widget _discoverWidget() {
    return SizedBox(
      height: 330,
      width: double.infinity,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: BasicShimmerContainer(Size(220, 30)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 20,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: .26 / 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (_, item) {
                  return const ListTile(
                    contentPadding: EdgeInsetsDirectional.all(5),
                    leading: BasicShimmerContainer(Size(52, 52)),
                    title: BasicShimmerContainer(Size(90, 18)),
                    subtitle: BasicShimmerContainer(Size(40, 14)),
                  );
                }),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _contentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 5),
          child: BasicShimmerContainer(Size(220, 28)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, index) {
                return Container(
                  width: 155,
                  padding: const EdgeInsets.only(left: 5.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 147,
                          child: BasicShimmerContainer(Size(147, 147))),
                      SizedBox(height: 10),
                      BasicShimmerContainer(Size(130, 18)),
                      SizedBox(height: 5),
                      BasicShimmerContainer(Size(90, 14)),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
