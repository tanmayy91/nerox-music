import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Settings/settings_screen_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.isBottomNavActive = false});
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 90.0;

    return Padding(
      padding: isBottomNavActive
          ? EdgeInsets.only(left: 20, top: topPadding, right: 15)
          : EdgeInsets.only(top: topPadding, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile".tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 200),
              children: [
                // ── Profile card ──────────────────────────────────────────
                Obx(() {
                  final signed = settingsController.isSignedIn.value;
                  final photoUrl = settingsController.userPhotoUrl.value;
                  return _ProfileCard(
                    signed: signed,
                    photoUrl: photoUrl,
                    displayName: settingsController.userDisplayName.value,
                    email: settingsController.userEmail.value,
                    onSignIn: () =>
                        _handleSignIn(context, settingsController),
                    onSignOut: settingsController.signOutGoogle,
                    isSigningIn: settingsController.isSigningIn.value,
                    onSetName: () => _showSetNameDialog(context, settingsController),
                  );
                }),
                const SizedBox(height: 20),

                // ── Listen Together ───────────────────────────────────────
                _SocialFeatureCard(
                  icon: Icons.headphones_rounded,
                  title: "listenTogether".tr,
                  subtitle: "listenTogetherDes".tr,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C3DE2), Color(0xFF9D6BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () =>
                      _showComingSoonSheet(context, "listenTogether".tr),
                  actionLabel: "startSession".tr,
                ),
                const SizedBox(height: 14),

                // ── Blend ──────────────────────────────────────────────────
                _SocialFeatureCard(
                  icon: Icons.shuffle_rounded,
                  title: "blend".tr,
                  subtitle: "blendDes".tr,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE2633D), Color(0xFFFF9D6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _showComingSoonSheet(context, "blend".tr),
                  actionLabel: "createBlend".tr,
                ),
                const SizedBox(height: 14),

                // ── Follow ─────────────────────────────────────────────────
                _SocialFeatureCard(
                  icon: Icons.people_rounded,
                  title: "follow".tr,
                  subtitle: "followDes".tr,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D9C5E), Color(0xFF6BFFA0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _showComingSoonSheet(context, "follow".tr),
                  actionLabel: "findFriends".tr,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(
      BuildContext context, SettingsScreenController ctrl) async {
    try {
      await ctrl.signInWithGoogle();
    } catch (_) {
      // Error already shown by the controller; nothing extra needed.
    }
  }

  void _showSetNameDialog(
      BuildContext context, SettingsScreenController ctrl) {
    final textCtrl =
        TextEditingController(text: ctrl.userDisplayName.value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("setDisplayName".tr),
        content: TextField(
          controller: textCtrl,
          decoration: InputDecoration(hintText: "enterYourName".tr),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("cancel".tr),
          ),
          FilledButton(
            onPressed: () {
              final name = textCtrl.text.trim();
              if (name.isNotEmpty) {
                ctrl.userDisplayName.value = name;
                ctrl.setBox.put('localDisplayName', name);
              }
              Navigator.of(ctx).pop();
            },
            child: Text("save".tr),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSheet(BuildContext context, String featureName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    Theme.of(ctx).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.rocket_launch_rounded,
                size: 48, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              featureName,
              style: Theme.of(ctx)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "comingSoon".tr,
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("ok".tr),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile card widget
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.signed,
    required this.photoUrl,
    required this.displayName,
    required this.email,
    required this.onSignIn,
    required this.onSignOut,
    required this.isSigningIn,
    required this.onSetName,
  });

  final bool signed;
  final String? photoUrl;
  final String displayName;
  final String email;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final bool isSigningIn;
  final VoidCallback onSetName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar — tappable to set name when not signed in
          GestureDetector(
            onTap: signed ? null : onSetName,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage:
                  (signed && photoUrl != null && photoUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(photoUrl!)
                      : null,
              child:
                  (signed && photoUrl != null && photoUrl!.isNotEmpty)
                      ? null
                      : (displayName.isNotEmpty
                          ? Text(
                              displayName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary,
                              ),
                            )
                          : Icon(Icons.person_rounded,
                              size: 38,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: signed
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(email,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  )
                : GestureDetector(
                    onTap: onSetName,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty
                              ? displayName
                              : "signInWithGoogle".tr,
                          style:
                              Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (displayName.isEmpty)
                          Text(
                            "tapToSetName".tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          isSigningIn
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                  onPressed: signed ? onSignOut : onSignIn,
                  child: Text(signed ? "signOut".tr : "signIn".tr),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social feature card widget
// ─────────────────────────────────────────────────────────────────────────────

class _SocialFeatureCard extends StatelessWidget {
  const _SocialFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                        maxLines: 2),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(actionLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
