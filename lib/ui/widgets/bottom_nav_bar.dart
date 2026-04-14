import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.75),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Obx(() => NavigationBar(
                    onDestinationSelected:
                        homeScreenController.onBottonBarTabSelected,
                    selectedIndex: homeScreenController.tabIndex.toInt(),
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    height: 64,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    animationDuration: const Duration(milliseconds: 350),
                    destinations: [
                      NavigationDestination(
                        selectedIcon: const Icon(Icons.home_rounded),
                        icon: const Icon(Icons.home_outlined),
                        label: modifyNgetlabel('home'.tr),
                      ),
                      NavigationDestination(
                        selectedIcon: const Icon(Icons.search_rounded),
                        icon: const Icon(Icons.search_rounded),
                        label: modifyNgetlabel('search'.tr),
                      ),
                      NavigationDestination(
                        selectedIcon: const Icon(Icons.library_music_rounded),
                        icon: const Icon(Icons.library_music_outlined),
                        label: modifyNgetlabel('library'.tr),
                      ),
                      NavigationDestination(
                        selectedIcon: const Icon(Icons.settings_rounded),
                        icon: const Icon(Icons.settings_outlined),
                        label: modifyNgetlabel('settings'.tr),
                      ),
                    ])),
          ),
        ),
      ),
    );
  }

  String modifyNgetlabel(String label) {
    if (label.length > 9) {
      return "${label.substring(0, 8)}..";
    }
    return label;
  }
}
