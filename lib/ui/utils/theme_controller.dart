import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:palette_generator/palette_generator.dart';
import '/utils/helper.dart';

class ThemeController extends GetxController {
  final primaryColor = Colors.deepPurple[400].obs;
  final textColor = Colors.white24.obs;
  final themedata = Rxn<ThemeData>();

  /// The method channel for setting the title bar color on Windows.
  final platform = const MethodChannel('win_titlebar_color');
  String? currentSongId;
  late Brightness systemBrightness;

  ThemeController() {
    systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    primaryColor.value =
        Color(Hive.box('AppPrefs').get("themePrimaryColor") ?? 4278199603);

    changeThemeModeType(
        ThemeType.values[Hive.box('AppPrefs').get("themeModeType") ?? 0]);

    _listenSystemBrightness();

    super.onInit();
  }

  void _listenSystemBrightness() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    platformDispatcher.onPlatformBrightnessChanged = () {
      systemBrightness = platformDispatcher.platformBrightness;
      changeThemeModeType(
          ThemeType.values[Hive.box('AppPrefs').get("themeModeType") ?? 0],
          sysCall: true);
    };
  }

  void changeThemeModeType(dynamic value, {bool sysCall = false}) {
    if (value == ThemeType.system) {
      themedata.value = _createThemeData(
          null,
          systemBrightness == Brightness.light
              ? ThemeType.light
              : ThemeType.dark);
    } else {
      if (sysCall) return;
      themedata.value = _createThemeData(
          value == ThemeType.dynamic
              ? _createMaterialColor(primaryColor.value!)
              : null,
          value);
    }
    setWindowsTitleBarColor(themedata.value!.scaffoldBackgroundColor);
  }

  void setTheme(ImageProvider imageProvider, String songId) async {
    if (songId == currentSongId) return;
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        ResizeImage(imageProvider, height: 200, width: 200));
    //final colorList = generator.colors;
    final paletteColor = generator.dominantColor ??
        generator.darkMutedColor ??
        generator.darkVibrantColor ??
        generator.lightMutedColor ??
        generator.lightVibrantColor;
    primaryColor.value = paletteColor!.color;
    textColor.value = paletteColor.bodyTextColor;
    // printINFO(paletteColor.color.computeLuminance().toString());0.11 ref
    if (paletteColor.color.computeLuminance() > 0.10) {
      primaryColor.value = paletteColor.color.withLightness(0.10);
      textColor.value = Colors.white54;
    }
    final primarySwatch = _createMaterialColor(primaryColor.value!);
    themedata.value = _createThemeData(primarySwatch, ThemeType.dynamic,
        textColor: textColor.value,
        titleColorSwatch: _createMaterialColor(textColor.value));
    currentSongId = songId;
    Hive.box('AppPrefs').put("themePrimaryColor", (primaryColor.value!).value);
    setWindowsTitleBarColor(themedata.value!.scaffoldBackgroundColor);
  }

  ThemeData _createThemeData(MaterialColor? primarySwatch, ThemeType themeType,
      {MaterialColor? titleColorSwatch, Color? textColor}) {
    if (themeType == ThemeType.dynamic) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white.withOpacity(0.002),
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: true),
      );

      final baseTheme = ThemeData(
          useMaterial3: true,
          primaryColor: primarySwatch![500],
          colorScheme: ColorScheme.fromSwatch(
              accentColor: primarySwatch[200],
              brightness: Brightness.dark,
              backgroundColor: primarySwatch[700],
              primarySwatch: primarySwatch),
          dialogBackgroundColor: primarySwatch[700],
          cardColor: primarySwatch[600],
          primaryColorLight: primarySwatch[400],
          primaryColorDark: primarySwatch[700],
          canvasColor: primarySwatch[700],
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: primarySwatch[600],
              modalBarrierColor: primarySwatch[400],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              )),
          textTheme: TextTheme(
            titleLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5),
            titleMedium: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.2),
            titleSmall: TextStyle(
                color: primarySwatch[100],
                fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(
                color: primarySwatch[100],
                fontWeight: FontWeight.w400),
            labelMedium: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: -0.5,
                color: textColor ?? primarySwatch[50]),
            labelSmall: TextStyle(
                fontSize: 14,
                color: titleColorSwatch != null
                    ? titleColorSwatch[900]
                    : primarySwatch[100],
                letterSpacing: 0.1,
                fontWeight: FontWeight.w600),
          ),
          indicatorColor: Colors.white,
          progressIndicatorTheme: ProgressIndicatorThemeData(
              linearTrackColor: (primarySwatch[300])!.computeLuminance() > 0.3
                  ? Colors.black54
                  : Colors.white70,
              color: textColor),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            backgroundColor: primarySwatch[700],
            indicatorColor: primarySwatch[400]?.withOpacity(0.3),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.white, size: 24);
              }
              return IconThemeData(color: primarySwatch[200], size: 24);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12);
              }
              return TextStyle(
                  color: primarySwatch[200],
                  fontWeight: FontWeight.w500,
                  fontSize: 12);
            }),
          ),
          navigationRailTheme: NavigationRailThemeData(
              backgroundColor: primarySwatch[700],
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: primarySwatch[100]),
              selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
              unselectedLabelTextStyle: TextStyle(
                  color: primarySwatch[100], fontWeight: FontWeight.w500)),
          sliderTheme: SliderThemeData(
            inactiveTrackColor: primarySwatch[300],
            activeTrackColor: textColor,
            valueIndicatorColor: primarySwatch[400],
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.1),
            trackHeight: 3,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primarySwatch[400],
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: primarySwatch[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: primarySwatch[200],
              selectionColor: primarySwatch[200],
              selectionHandleColor: primarySwatch[200]),
          );
      return baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme));
    } else if (themeType == ThemeType.dark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white.withOpacity(0.002),
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: true),
      );

      // V3 Premium dark: deep blacks with electric accent
      const darkSurface = Color(0xFF030304);
      const darkCard = Color(0xFF0E0E14);
      const darkElevated = Color(0xFF16161F);
      const neonAccent = Color(0xFF9D6BFF); // Electric violet
      const neonGlow = Color(0xFFB388FF); // Lighter glow variant
      const subtleWhite = Color(0xFFE8E8F0);

      final baseTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          canvasColor: darkSurface,
          primaryColor: darkSurface,
          primaryColorDark: darkSurface,
          primaryColorLight: darkCard,
          scaffoldBackgroundColor: darkSurface,
          colorScheme: ColorScheme.dark(
            surface: darkSurface,
            primary: subtleWhite,
            secondary: darkElevated,
            tertiary: neonAccent.withOpacity(0.15),
            onSurface: subtleWhite,
            onPrimary: darkSurface,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: neonAccent,
              linearTrackColor: subtleWhite),
          textTheme: TextTheme(
              titleLarge: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: subtleWhite,
              ),
              titleMedium: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: subtleWhite.withOpacity(0.95),
              ),
              titleSmall: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
              labelMedium: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 28,
                letterSpacing: -1.0,
                color: subtleWhite,
              ),
              labelSmall: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w600,
                  color: subtleWhite.withOpacity(0.7)),
              bodyMedium: TextStyle(
                  color: Colors.white.withOpacity(0.40),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1)),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            height: 68,
            backgroundColor: darkSurface,
            indicatorColor: neonAccent.withOpacity(0.15),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: neonGlow, size: 26);
              }
              return IconThemeData(
                  color: Colors.white.withOpacity(0.30), size: 23);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: subtleWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.3);
              }
              return TextStyle(
                  color: Colors.white.withOpacity(0.30),
                  fontWeight: FontWeight.w500,
                  fontSize: 11);
            }),
          ),
          navigationRailTheme: NavigationRailThemeData(
              backgroundColor: darkSurface,
              selectedIconTheme: const IconThemeData(color: neonGlow),
              unselectedIconTheme:
                  IconThemeData(color: Colors.white.withOpacity(0.25)),
              selectedLabelTextStyle: const TextStyle(
                  color: subtleWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
              unselectedLabelTextStyle: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontWeight: FontWeight.w500)),
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: darkCard,
              modalBarrierColor: Colors.black.withOpacity(0.80),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              )),
          sliderTheme: SliderThemeData(
            inactiveTrackColor: Colors.white.withOpacity(0.08),
            activeTrackColor: neonAccent,
            valueIndicatorColor: darkElevated,
            thumbColor: Colors.white,
            overlayColor: neonAccent.withOpacity(0.15),
            trackHeight: 4,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: neonAccent,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          cardTheme: CardTheme(
            color: darkCard,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: neonAccent,
              selectionColor: neonAccent.withOpacity(0.3),
              selectionHandleColor: neonAccent),
          inputDecorationTheme: InputDecorationTheme(
              focusColor: neonAccent,
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: neonAccent.withOpacity(0.7)))));
      return baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme));
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white.withOpacity(0.002),
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: false),
      );

      // V3 Premium light: warm cream with rich charcoal
      const lightSurface = Color(0xFFF5F4F0);
      const lightCard = Color(0xFFFFFFFF);
      const charcoal = Color(0xFF141416);
      const warmAccent = Color(0xFF6D5BFF); // Warm indigo accent
      final softGray = Colors.grey[500]!;

      final baseTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          canvasColor: lightSurface,
          colorScheme: ColorScheme.light(
            surface: lightSurface,
            primary: charcoal,
            secondary: const Color(0xFFEAE9E5),
            tertiary: warmAccent.withOpacity(0.08),
            onSurface: charcoal,
            onPrimary: lightCard,
          ),
          primaryColor: lightSurface,
          primaryColorLight: const Color(0xFFEAE9E5),
          progressIndicatorTheme: ProgressIndicatorThemeData(
              linearTrackColor: charcoal,
              color: softGray.withOpacity(0.25)),
          textTheme: TextTheme(
              titleLarge: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: charcoal,
                letterSpacing: -0.8,
              ),
              titleMedium: const TextStyle(
                fontWeight: FontWeight.w600,
                color: charcoal,
                letterSpacing: -0.2,
              ),
              titleSmall: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              labelMedium: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: charcoal,
                letterSpacing: -0.8,
              ),
              labelSmall: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
              bodyMedium: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400)),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            height: 68,
            backgroundColor: lightSurface,
            indicatorColor: warmAccent.withOpacity(0.10),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: charcoal, size: 25);
              }
              return IconThemeData(color: Colors.grey[400], size: 23);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: charcoal,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.3);
              }
              return TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                  fontSize: 11);
            }),
          ),
          navigationRailTheme: NavigationRailThemeData(
              backgroundColor: lightSurface,
              selectedIconTheme: const IconThemeData(color: charcoal),
              unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
              selectedLabelTextStyle: const TextStyle(
                  color: charcoal,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
              unselectedLabelTextStyle: TextStyle(
                  color: Colors.grey[400], fontWeight: FontWeight.w500)),
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: lightCard,
              modalBarrierColor: Colors.black.withOpacity(0.25),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              )),
          sliderTheme: SliderThemeData(
            inactiveTrackColor: Colors.black.withOpacity(0.08),
            activeTrackColor: charcoal,
            valueIndicatorColor: const Color(0xFFEAE9E5),
            thumbColor: charcoal,
            overlayColor: Colors.black.withOpacity(0.04),
            trackHeight: 4,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: charcoal,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          cardTheme: CardTheme(
            color: lightCard,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: warmAccent,
              selectionColor: warmAccent.withOpacity(0.25),
              selectionHandleColor: warmAccent),
          inputDecorationTheme: InputDecorationTheme(
              focusColor: charcoal,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: charcoal.withOpacity(0.8)))));
      return baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme));
    }
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  Future<void> setWindowsTitleBarColor(Color color) async {
    if (!GetPlatform.isWindows) return;
    try {
      Future.delayed(
          const Duration(milliseconds: 350),
          () async => await platform.invokeMethod('setTitleBarColor', {
                'r': color.red,
                'g': color.green,
                'b': color.blue,
              }));
    } on PlatformException catch (e) {
      printERROR("Failed to set title bar color: ${e.message}");
    }
  }
}

extension ComplementaryColor on Color {
  Color get complementaryColor => getComplementaryColor(this);
  Color getComplementaryColor(Color color) {
    int r = 255 - color.red;
    int g = 255 - color.green;
    int b = 255 - color.blue;
    return Color.fromARGB(color.alpha, r, g, b);
  }
}

extension ColorWithHSL on Color {
  HSLColor get hsl => HSLColor.fromColor(this);

  Color withSaturation(double saturation) {
    return hsl.withSaturation(clampDouble(saturation, 0.0, 1.0)).toColor();
  }

  Color withLightness(double lightness) {
    return hsl.withLightness(clampDouble(lightness, 0.0, 1.0)).toColor();
  }

  Color withHue(double hue) {
    return hsl.withHue(clampDouble(hue, 0.0, 360.0)).toColor();
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

enum ThemeType {
  dynamic,
  system,
  dark,
  light,
}
