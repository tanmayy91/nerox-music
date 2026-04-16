import '/services/auth_service.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/permission_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/update_check_flag_file.dart';
import '/services/piped_service.dart';
import '../Library/library_controller.dart';
import '../../widgets/snackbar.dart';
import '../../../utils/helper.dart';
import '/services/music_service.dart';
import '/ui/player/player_controller.dart';
import '../Home/home_screen_controller.dart';
import '/ui/utils/theme_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsScreenController extends GetxController {
  late String _supportDir;
  final cacheSongs = false.obs;
  final setBox = Hive.box("AppPrefs");
  final themeModetype = ThemeType.dynamic.obs;
  final skipSilenceEnabled = false.obs;
  final loudnessNormalizationEnabled = false.obs;
  final noOfHomeScreenContent = 3.obs;
  final streamingQuality = AudioQuality.High.obs;
  final playerUi = 0.obs;
  final slidableActionEnabled = true.obs;
  final isIgnoringBatteryOptimizations = false.obs;
  final autoOpenPlayer = false.obs;
  final discoverContentType = "QP".obs;
  final isNewVersionAvailable = false.obs;
  final isLinkedWithPiped = false.obs;
  final stopPlyabackOnSwipeAway = false.obs;
  final currentAppLanguageCode = "en".obs;
  final downloadLocationPath = "".obs;
  final exportLocationPath = "".obs;
  final downloadingFormat = "".obs;
  final autoDownloadFavoriteSongEnabled = false.obs;
  final isTransitionAnimationDisabled = false.obs;
  final isBottomNavBarEnabled = false.obs;
  final backgroundPlayEnabled = true.obs;
  final keepScreenAwake = false.obs;
  final restorePlaybackSession = false.obs;
  final cacheHomeScreenData = true.obs;
  final currentVersion = "V3.0.0";

  // Google Auth state
  final isSignedIn = false.obs;
  final userDisplayName = ''.obs;
  final userEmail = ''.obs;
  final userPhotoUrl = RxnString();
  final isSigningIn = false.obs;

  @override
  void onInit() {
    _setInitValue();
    _loadAuthState();
    if (updateCheckFlag) _checkNewVersion();
    _createInAppSongDownDir();
    super.onInit();
  }

  get currentVision => currentVersion;
  get isCurrentPathsupportDownDir =>
      "$_supportDir/Music" == downloadLocationPath.toString();
  String get supportDirPath => _supportDir;

  _checkNewVersion() {
    newVersionCheck(currentVersion)
        .then((value) => isNewVersionAvailable.value = value);
  }

  Future<String> _createInAppSongDownDir() async {
    _supportDir = (await getApplicationSupportDirectory()).path;
    final directory = Directory("$_supportDir/Music/");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return "$_supportDir/Music";
  }

  Future<void> _setInitValue() async {
    final appLang = setBox.get('currentAppLanguageCode') ?? "en";
    currentAppLanguageCode.value = appLang == "zh_Hant"
        ? "zh-TW"
        : appLang == "zh_Hans"
            ? "zh-CN"
            : appLang;
    isBottomNavBarEnabled.value =
        setBox.get("isBottomNavBarEnabled") ?? true;
    noOfHomeScreenContent.value = setBox.get("noOfHomeScreenContent") ?? 3;
    isTransitionAnimationDisabled.value =
        setBox.get("isTransitionAnimationDisabled") ?? false;
    cacheSongs.value = setBox.get('cacheSongs') ?? false;
    themeModetype.value = ThemeType.values[setBox.get('themeModeType') ?? 0];
    skipSilenceEnabled.value = setBox.get("skipSilenceEnabled");
    loudnessNormalizationEnabled.value =
        setBox.get("loudnessNormalizationEnabled") ?? false;
    autoOpenPlayer.value = (setBox.get("autoOpenPlayer") ?? true);
    restorePlaybackSession.value =
        setBox.get("restrorePlaybackSession") ?? false;
    cacheHomeScreenData.value = setBox.get("cacheHomeScreenData") ?? true;
    streamingQuality.value =
        AudioQuality.values[setBox.get('streamingQuality')];
    playerUi.value = setBox.get('playerUi') ?? 0;
    backgroundPlayEnabled.value = setBox.get("backgroundPlayEnabled") ?? true;
    keepScreenAwake.value = setBox.get("keepScreenAwake") ?? false;
    final downloadPath =
        setBox.get('downloadLocationPath') ?? await _createInAppSongDownDir();
    downloadLocationPath.value = downloadPath;

    exportLocationPath.value =
        setBox.get("exportLocationPath") ?? "/storage/emulated/0/Music";
    downloadingFormat.value = setBox.get('downloadingFormat') ?? "m4a";
    discoverContentType.value = setBox.get('discoverContentType') ?? "QP";
    slidableActionEnabled.value = setBox.get('slidableActionEnabled') ?? true;
    if (setBox.containsKey("piped")) {
      isLinkedWithPiped.value = setBox.get("piped")['isLoggedIn'];
    }
    stopPlyabackOnSwipeAway.value =
        setBox.get('stopPlyabackOnSwipeAway') ?? false;
    if (GetPlatform.isAndroid) {
      isIgnoringBatteryOptimizations.value =
          (await Permission.ignoreBatteryOptimizations.isGranted);
    }
    autoDownloadFavoriteSongEnabled.value =
        setBox.get("autoDownloadFavoriteSongEnabled") ?? false;
  }

  void setAppLanguage(String? val) {
    Get.updateLocale(Locale(val!));
    Get.find<MusicServices>().hlCode = val;
    Get.find<HomeScreenController>().loadContentFromNetwork(silent: true);
    currentAppLanguageCode.value = val;
    setBox.put('currentAppLanguageCode', val);
  }

  void setContentNumber(int? no) {
    noOfHomeScreenContent.value = no!;
    setBox.put("noOfHomeScreenContent", no);
  }

  void setStreamingQuality(dynamic val) {
    setBox.put("streamingQuality", AudioQuality.values.indexOf(val));
    streamingQuality.value = val;
  }

  void setPlayerUi(dynamic val) {
    final playerCon = Get.find<PlayerController>();
    setBox.put("playerUi", val);
    if (val == 1 && playerCon.gesturePlayerStateAnimationController == null) {
      playerCon.initGesturePlayerStateAnimationController();
    }

    playerUi.value = val;
  }

  void enableBottomNavBar(bool val) {
    final homeScrCon = Get.find<HomeScreenController>();
    final playerCon = Get.find<PlayerController>();
    if (val) {
      homeScrCon.onSideBarTabSelected(3);
      isBottomNavBarEnabled.value = true;
    } else {
      isBottomNavBarEnabled.value = false;
      homeScrCon.onSideBarTabSelected(5);
    }
    if (!Get.find<PlayerController>().initFlagForPlayer) {
      playerCon.playerPanelMinHeight.value =
          val ? 75.0 : 75.0 + Get.mediaQuery.viewPadding.bottom;
    }
    setBox.put("isBottomNavBarEnabled", val);
  }

  void toggleSlidableAction(bool val) {
    setBox.put("slidableActionEnabled", val);
    slidableActionEnabled.value = val;
  }

  void changeDownloadingFormat(String? val) {
    setBox.put("downloadingFormat", val);
    downloadingFormat.value = val!;
  }

  Future<void> setExportedLocation() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    final String? pickedFolderPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Select export file folder");
    if (pickedFolderPath == '/' || pickedFolderPath == null) {
      return;
    }

    setBox.put("exportLocationPath", pickedFolderPath);
    exportLocationPath.value = pickedFolderPath;
  }

  Future<void> setDownloadLocation() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    final String? pickedFolderPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Select downloads folder");
    if (pickedFolderPath == '/' || pickedFolderPath == null) {
      return;
    }

    setBox.put("downloadLocationPath", pickedFolderPath);
    downloadLocationPath.value = pickedFolderPath;
  }

  void disableTransitionAnimation(bool val) {
    setBox.put('isTransitionAnimationDisabled', val);
    isTransitionAnimationDisabled.value = val;
  }

  Future<void> clearImagesCache() async {
    final tempImgDirPath =
        "${(await getApplicationCacheDirectory()).path}/libCachedImageData";
    final tempImgDir = Directory(tempImgDirPath);
    try {
      if (await tempImgDir.exists()) {
        await tempImgDir.delete(recursive: true);
      }
    } catch (e) {
      printERROR("Failed to clear image cache: $e");
    }
  }

  void resetDownloadLocation() {
    final defaultPath = "$_supportDir/Music";
    setBox.put("downloadLocationPath", defaultPath);
    downloadLocationPath.value = defaultPath;
  }

  void onThemeChange(dynamic val) {
    setBox.put('themeModeType', ThemeType.values.indexOf(val));
    themeModetype.value = val;
    Get.find<ThemeController>().changeThemeModeType(val);
  }

  void onContentChange(dynamic value) {
    setBox.put('discoverContentType', value);
    discoverContentType.value = value;
    Get.find<HomeScreenController>().changeDiscoverContent(value);
  }

  void toggleCachingSongsValue(bool value) {
    setBox.put("cacheSongs", value);
    cacheSongs.value = value;
  }

  void toggleSkipSilence(bool val) {
    Get.find<PlayerController>().toggleSkipSilence(val);
    setBox.put('skipSilenceEnabled', val);
    skipSilenceEnabled.value = val;
  }

  void toggleLoudnessNormalization(bool val) {
    Get.find<PlayerController>().toggleLoudnessNormalization(val);
    setBox.put("loudnessNormalizationEnabled", val);
    loudnessNormalizationEnabled.value = val;
  }

  void toggleRestorePlaybackSession(bool val) {
    setBox.put("restrorePlaybackSession", val);
    restorePlaybackSession.value = val;
  }

  Future<void> toggleCacheHomeScreenData(bool val) async {
    setBox.put("cacheHomeScreenData", val);
    cacheHomeScreenData.value = val;
    if (!val) {
      Hive.openBox("homeScreenData").then((box) async {
        await box.clear();
        await box.close();
      });
    } else {
      await Hive.openBox("homeScreenData");
      Get.find<HomeScreenController>().cachedHomeScreenData(updateAll: true);
    }
  }

  void toggleAutoDownloadFavoriteSong(bool val) {
    setBox.put("autoDownloadFavoriteSongEnabled", val);
    autoDownloadFavoriteSongEnabled.value = val;
  }

  void toggleBackgroundPlay(bool val) {
    setBox.put('backgroundPlayEnabled', val);
    backgroundPlayEnabled.value = val;
  }

  void toggleKeepScreenAwake(bool val) {
    setBox.put('keepScreenAwake', val);
    keepScreenAwake.value = val;
    try {
        if (val) {
          // enable wakelock immediately if music is playing
          if (Get.find<PlayerController>().buttonState.value ==
              PlayButtonState.playing) {
            WakelockPlus.enable();
          }
        } else {
          WakelockPlus.disable();
        }
     
    } catch (e) {
      // ignore if player/controller not available
    }
  }

  Future<void> enableIgnoringBatteryOptimizations() async {
    await Permission.ignoreBatteryOptimizations.request();
    isIgnoringBatteryOptimizations.value =
        await Permission.ignoreBatteryOptimizations.isGranted;
  }

  void toggleAutoOpenPlayer(bool val) {
    setBox.put('autoOpenPlayer', val);
    autoOpenPlayer.value = val;
  }

  Future<void> unlinkPiped() async {
    Get.find<PipedServices>().logout();
    isLinkedWithPiped.value = false;
    Get.find<LibraryPlaylistsController>().removePipedPlaylists();
    final box = await Hive.openBox('blacklistedPlaylist');
    box.clear();
    ScaffoldMessenger.of(Get.context!).showSnackBar(
        snackbar(Get.context!, "unlinkAlert".tr, size: SanckBarSize.MEDIUM));
    box.close();
  }

  Future<void> resetAppSettingsToDefault() async {
    await setBox.clear();
  }

  void toggleStopPlyabackOnSwipeAway(bool val) {
    setBox.put('stopPlyabackOnSwipeAway', val);
    stopPlyabackOnSwipeAway.value = val;
  }

  void _loadAuthState() {
    final auth = Get.find<AuthService>();
    isSignedIn.value = auth.isSignedIn;
    userDisplayName.value = auth.isSignedIn
        ? auth.displayName
        : (setBox.get('localDisplayName', defaultValue: '') as String);
    userEmail.value = auth.email;
    userPhotoUrl.value = auth.photoUrl;
  }

  /// Called from main.dart after AuthService is ready; restores session and
  /// refreshes the observable state so the UI reflects the restored user.
  Future<void> restoreAndRefreshAuthState() async {
    final auth = Get.find<AuthService>();
    final restored = await auth.restoreSession();
    if (restored) {
      isSignedIn.value = auth.isSignedIn;
      userDisplayName.value = auth.displayName;
      userEmail.value = auth.email;
      userPhotoUrl.value = auth.photoUrl;
    }
  }

  Future<void> signInWithGoogle() async {
    if (isSigningIn.value) return;
    isSigningIn.value = true;
    try {
      final auth = Get.find<AuthService>();
      final success = await auth.signIn();
      if (success) {
        isSignedIn.value = true;
        userDisplayName.value = auth.displayName;
        userEmail.value = auth.email;
        userPhotoUrl.value = auth.photoUrl;
        ScaffoldMessenger.of(Get.context!).showSnackBar(
            snackbar(Get.context!, "${"signedInAs".tr} ${auth.displayName}",
                size: SanckBarSize.MEDIUM));
      }
      // success == false means the user dismissed the picker; no error shown.
    } on PlatformException catch (e) {
      // Build a message that includes the error code so configuration issues
      // are diagnosable without needing ADB logs.
      final codeInfo = e.code.isNotEmpty ? ' (${e.code})' : '';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
          snackbar(Get.context!, "${"googleSignInFailed".tr}$codeInfo",
              size: SanckBarSize.MEDIUM));
      printERROR('signInWithGoogle PlatformException [${e.code}]: ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
          snackbar(Get.context!, "googleSignInFailed".tr,
              size: SanckBarSize.MEDIUM));
      printERROR('signInWithGoogle: $e');
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signOutGoogle() async {
    final auth = Get.find<AuthService>();
    await auth.signOut();
    isSignedIn.value = false;
    userDisplayName.value = '';
    userEmail.value = '';
    userPhotoUrl.value = null;
    ScaffoldMessenger.of(Get.context!).showSnackBar(
        snackbar(Get.context!, "signOut".tr, size: SanckBarSize.MEDIUM));
  }

  Future<void> closeAllDatabases() async {
    await Hive.close();
  }

  Future<String> get dbDir async {
    return (await getApplicationDocumentsDirectory()).path;
  }
}
