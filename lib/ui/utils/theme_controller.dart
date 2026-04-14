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
        Color(Hive.box('appPrefs').get("themePrimaryColor") ?? 4278199603);

    changeThemeModeType(
        ThemeType.values[Hive.box('appPrefs').get("themeModeType") ?? 0]);

    _listenSystemBrightness();

    super.onInit();
  }

  void _listenSystemBrightness() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    platformDispatcher.onPlatformBrightnessChanged = () {
      systemBrightness = platformDispatcher.platformBrightness;
      changeThemeModeType(
          ThemeType.values[Hive.box('appPrefs').get("themeModeType")],
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
    Hive.box('appPrefs').put("themePrimaryColor", (primaryColor.value!).value);
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

      const darkSurface = Color(0xFF0F0F0F);
      const darkCard = Color(0xFF1A1A1A);
      const darkElevated = Color(0xFF242424);

      final baseTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          canvasColor: darkSurface,
          primaryColor: darkSurface,
          primaryColorDark: darkSurface,
          primaryColorLight: darkCard,
          colorScheme: ColorScheme.dark(
            surface: darkSurface,
            primary: Colors.white,
            secondary: darkElevated,
            tertiary: Colors.white.withOpacity(0.08),
            onSurface: Colors.white,
            onPrimary: darkSurface,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
              color: Colors.white.withOpacity(0.3),
              linearTrackColor: Colors.white),
          textTheme: TextTheme(
              titleLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              titleMedium: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              titleSmall: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
              labelMedium: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
              labelSmall: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontWeight: FontWeight.w400)),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            backgroundColor: darkSurface,
            indicatorColor: Colors.white.withOpacity(0.08),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.white, size: 24);
              }
              return IconThemeData(
                  color: Colors.white.withOpacity(0.45), size: 24);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12);
              }
              return TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontWeight: FontWeight.w500,
                  fontSize: 12);
            }),
          ),
          navigationRailTheme: NavigationRailThemeData(
              backgroundColor: darkSurface,
              selectedIconTheme: const IconThemeData(
                color: Colors.white,
              ),
              unselectedIconTheme:
                  IconThemeData(color: Colors.white.withOpacity(0.4)),
              selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
              unselectedLabelTextStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w500)),
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: darkCard,
              modalBarrierColor: Colors.black.withOpacity(0.6),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              )),
          sliderTheme: SliderThemeData(
            inactiveTrackColor: Colors.white.withOpacity(0.15),
            activeTrackColor: Colors.white,
            valueIndicatorColor: darkElevated,
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.1),
            trackHeight: 3,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.white,
            foregroundColor: darkSurface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.white.withOpacity(0.6),
              selectionColor: Colors.white.withOpacity(0.3),
              selectionHandleColor: Colors.white.withOpacity(0.6)),
          inputDecorationTheme: InputDecorationTheme(
              focusColor: Colors.white,
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.6)))));
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

      const lightSurface = Color(0xFFF8F8FA);
      const lightCard = Color(0xFFFFFFFF);
      final lightMuted = Colors.grey[500]!;

      final baseTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          canvasColor: lightSurface,
          colorScheme: ColorScheme.light(
            surface: lightSurface,
            primary: const Color(0xFF1A1A1A),
            secondary: const Color(0xFFE8E8EC),
            tertiary: Colors.black.withOpacity(0.05),
            onSurface: const Color(0xFF1A1A1A),
            onPrimary: lightCard,
          ),
          primaryColor: lightSurface,
          primaryColorLight: const Color(0xFFE8E8EC),
          progressIndicatorTheme: ProgressIndicatorThemeData(
              linearTrackColor: const Color(0xFF1A1A1A),
              color: lightMuted.withOpacity(0.3)),
          textTheme: TextTheme(
              titleLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
              titleMedium: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.2,
              ),
              titleSmall: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              labelMedium: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
              labelSmall: TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
              bodyMedium: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400)),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            backgroundColor: lightSurface,
            indicatorColor: Colors.black.withOpacity(0.06),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                    color: Color(0xFF1A1A1A), size: 24);
              }
              return IconThemeData(color: Colors.grey[500], size: 24);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                    fontSize: 12);
              }
              return TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  fontSize: 12);
            }),
          ),
          navigationRailTheme: NavigationRailThemeData(
              backgroundColor: lightSurface,
              selectedIconTheme:
                  const IconThemeData(color: Color(0xFF1A1A1A)),
              unselectedIconTheme: IconThemeData(color: Colors.grey[500]),
              selectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
              unselectedLabelTextStyle: TextStyle(
                  color: Colors.grey[500], fontWeight: FontWeight.w500)),
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: lightCard,
              modalBarrierColor: Colors.black.withOpacity(0.3),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              )),
          sliderTheme: SliderThemeData(
            inactiveTrackColor: Colors.black.withOpacity(0.12),
            activeTrackColor: const Color(0xFF1A1A1A),
            valueIndicatorColor: const Color(0xFFE8E8EC),
            thumbColor: const Color(0xFF1A1A1A),
            overlayColor: Colors.black.withOpacity(0.05),
            trackHeight: 3,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFF1A1A1A),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.grey[600],
              selectionColor: Colors.grey[400],
              selectionHandleColor: Colors.grey[600]),
          inputDecorationTheme: const InputDecorationTheme(
              focusColor: Color(0xFF1A1A1A),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A1A1A)))));
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
