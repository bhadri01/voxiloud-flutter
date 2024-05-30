import 'package:flutter/material.dart';

class ThemeClass {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
        primary: hexToColor('#67558F'),
        onPrimary: hexToColor('#fffffe'),
        primaryContainer: hexToColor('#e8ddff'),
        onPrimaryContainer: hexToColor('#211147'),
        secondary: hexToColor('#625a6f'),
        onSecondary: hexToColor('#fffffe'),
        secondaryContainer: hexToColor('#e8dff7'),
        onSecondaryContainer: hexToColor('#1e1a2b'),
        tertiary: hexToColor('#7e525f'),
        onTertiary: hexToColor('#fffffe'),
        tertiaryContainer: hexToColor('#fed9e1'),
        onTertiaryContainer: hexToColor('#30101d'),
        error: hexToColor('#ba1a1a'),
        onError: hexToColor('#fffffe'),
        errorContainer: hexToColor('#ffdad7'),
        onErrorContainer: hexToColor('#410102'),
        surface: hexToColor('#fef7ff'),
        onSurface: hexToColor('#1d1b20'),
        // surfaceContainer: hexToColor('#f6f0f8'),
        surfaceContainerHigh: hexToColor('#f6f0f8'),
        surfaceTint: hexToColor('#67558f'),
        outline: hexToColor('#7b757f'),
        outlineVariant: hexToColor('#cac4ce'),
        inverseSurface: hexToColor('#323035'),
        onInverseSurface: hexToColor('#f4eff6'),
        inversePrimary: hexToColor('#d1bcff'),
        scrim: hexToColor('#000000'),
        shadow: hexToColor('#000000')),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: hexToColor('#d1bcff'),
      onPrimary: hexToColor('#37265d'),
      primaryContainer: hexToColor('#4c3d75'),
      onPrimaryContainer: hexToColor('#e8ddff'),
      secondary: hexToColor('#ccc2db'),
      onSecondary: hexToColor('#322d40'),
      secondaryContainer: hexToColor('#494458'),
      onSecondaryContainer: hexToColor('#e8def7'),
      tertiary: hexToColor('#eeb9c6'),
      onTertiary: hexToColor('#4a2431'),
      tertiaryContainer: hexToColor('#633a48'),
      onTertiaryContainer: hexToColor('#fed9e1'),
      error: hexToColor('#feb4ab'),
      onError: hexToColor('#690005'),
      errorContainer: hexToColor('#ffcacc'),
      onErrorContainer: hexToColor('#ffced0'),
      surface: hexToColor('#141119'),
      onSurface: hexToColor('#e7e0e8'),
      // surfaceContainer: hexToColor('#1e1d23'),
      surfaceContainerHigh: hexToColor('#1e1d23'),
      surfaceTint: hexToColor('#d1bcff'),
      outline: hexToColor('#958f99'),
      outlineVariant: hexToColor('#48454d'),
      inverseSurface: hexToColor('#e6e0e9'),
      onInverseSurface: hexToColor('#e5e1e8'),
      inversePrimary: hexToColor('#675590'),
      scrim: hexToColor('#000000'),
      shadow: hexToColor('#000000'),
    ),
  );

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha value if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }
}
