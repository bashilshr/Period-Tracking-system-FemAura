import "package:flutter/material.dart";

class FemAuraTheme {
  final TextTheme textTheme;

  const FemAuraTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8a4a64),
      surfaceTint: Color(0xff8a4a64),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffd9e4),
      onPrimaryContainer: Color(0xff6f334c),
      secondary: Color(0xff735760),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffd9e4),
      onSecondaryContainer: Color(0xff5a3f49),
      tertiary: Color(0xff7d5637),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffdcc4),
      onTertiaryContainer: Color(0xff633e22),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f8),
      onSurface: Color(0xff21191c),
      onSurfaceVariant: Color(0xff514347),
      outline: Color(0xff837377),
      outlineVariant: Color(0xffd5c2c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff372e31),
      inversePrimary: Color(0xffffb0cd),
      primaryFixed: Color(0xffffd9e4),
      onPrimaryFixed: Color(0xff390720),
      primaryFixedDim: Color(0xffffb0cd),
      onPrimaryFixedVariant: Color(0xff6f334c),
      secondaryFixed: Color(0xffffd9e4),
      onSecondaryFixed: Color(0xff2a151d),
      secondaryFixedDim: Color(0xffe1bdc8),
      onSecondaryFixedVariant: Color(0xff5a3f49),
      tertiaryFixed: Color(0xffffdcc4),
      onTertiaryFixed: Color(0xff2f1400),
      tertiaryFixedDim: Color(0xfff0bc96),
      onTertiaryFixedVariant: Color(0xff633e22),
      surfaceDim: Color(0xffe6d6da),
      surfaceBright: Color(0xfffff8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0f3),
      surfaceContainer: Color(0xfffaeaed),
      surfaceContainerHigh: Color(0xfff4e4e8),
      surfaceContainerHighest: Color(0xffeedfe2),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5b233b),
      surfaceTint: Color(0xff8a4a64),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9b5873),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff482f38),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff83656f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4f2e13),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8e6444),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f8),
      onSurface: Color(0xff170f12),
      onSurfaceVariant: Color(0xff3f3337),
      outline: Color(0xff5d4f53),
      outlineVariant: Color(0xff78696d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff372e31),
      inversePrimary: Color(0xffffb0cd),
      primaryFixed: Color(0xff9b5873),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff7f415b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff83656f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff694d57),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff8e6444),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff734c2e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd2c3c6),
      surfaceBright: Color(0xfffff8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0f3),
      surfaceContainer: Color(0xfff4e4e8),
      surfaceContainerHigh: Color(0xffe9d9dc),
      surfaceContainerHighest: Color(0xffddced1),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff4e1831),
      surfaceTint: Color(0xff8a4a64),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff71354f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3d252e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5c424b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff43240a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff654124),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff35292d),
      outlineVariant: Color(0xff53464a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff372e31),
      inversePrimary: Color(0xffffb0cd),
      primaryFixed: Color(0xff71354f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff561f38),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5c424b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff442c35),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff654124),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4b2b10),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc4b5b8),
      surfaceBright: Color(0xfffff8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffdedf0),
      surfaceContainer: Color(0xffeedfe2),
      surfaceContainerHigh: Color(0xffe0d1d4),
      surfaceContainerHighest: Color(0xffd2c3c6),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb0cd),
      surfaceTint: Color(0xffffb0cd),
      onPrimary: Color(0xff531d36),
      primaryContainer: Color(0xff6f334c),
      onPrimaryContainer: Color(0xffffd9e4),
      secondary: Color(0xffe1bdc8),
      onSecondary: Color(0xff412932),
      secondaryContainer: Color(0xff5a3f49),
      onSecondaryContainer: Color(0xffffd9e4),
      tertiary: Color(0xfff0bc96),
      onTertiary: Color(0xff49290e),
      tertiaryContainer: Color(0xff633e22),
      onTertiaryContainer: Color(0xffffdcc4),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff191114),
      onSurface: Color(0xffeedfe2),
      onSurfaceVariant: Color(0xffd5c2c7),
      outline: Color(0xff9d8c91),
      outlineVariant: Color(0xff514347),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffeedfe2),
      inversePrimary: Color(0xff8a4a64),
      primaryFixed: Color(0xffffd9e4),
      onPrimaryFixed: Color(0xff390720),
      primaryFixedDim: Color(0xffffb0cd),
      onPrimaryFixedVariant: Color(0xff6f334c),
      secondaryFixed: Color(0xffffd9e4),
      onSecondaryFixed: Color(0xff2a151d),
      secondaryFixedDim: Color(0xffe1bdc8),
      onSecondaryFixedVariant: Color(0xff5a3f49),
      tertiaryFixed: Color(0xffffdcc4),
      onTertiaryFixed: Color(0xff2f1400),
      tertiaryFixedDim: Color(0xfff0bc96),
      onTertiaryFixedVariant: Color(0xff633e22),
      surfaceDim: Color(0xff191114),
      surfaceBright: Color(0xff403739),
      surfaceContainerLowest: Color(0xff130c0f),
      surfaceContainerLow: Color(0xff21191c),
      surfaceContainer: Color(0xff261d20),
      surfaceContainerHigh: Color(0xff30282a),
      surfaceContainerHighest: Color(0xff3c3235),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd0df),
      surfaceTint: Color(0xffffb0cd),
      onPrimary: Color(0xff46122b),
      primaryContainer: Color(0xffc47b97),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfff8d3de),
      onSecondary: Color(0xff361f28),
      secondaryContainer: Color(0xffa98893),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd4b6),
      onTertiary: Color(0xff3c1e05),
      tertiaryContainer: Color(0xffb68764),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff191114),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffebd7dc),
      outline: Color(0xffc0adb2),
      outlineVariant: Color(0xff9d8c91),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffeedfe2),
      inversePrimary: Color(0xff70344e),
      primaryFixed: Color(0xffffd9e4),
      onPrimaryFixed: Color(0xff2b0015),
      primaryFixedDim: Color(0xffffb0cd),
      onPrimaryFixedVariant: Color(0xff5b233b),
      secondaryFixed: Color(0xffffd9e4),
      onSecondaryFixed: Color(0xff1e0b13),
      secondaryFixedDim: Color(0xffe1bdc8),
      onSecondaryFixedVariant: Color(0xff482f38),
      tertiaryFixed: Color(0xffffdcc4),
      onTertiaryFixed: Color(0xff200c00),
      tertiaryFixedDim: Color(0xfff0bc96),
      onTertiaryFixedVariant: Color(0xff4f2e13),
      surfaceDim: Color(0xff191114),
      surfaceBright: Color(0xff4c4245),
      surfaceContainerLowest: Color(0xff0c0608),
      surfaceContainerLow: Color(0xff241b1e),
      surfaceContainer: Color(0xff2e2628),
      surfaceContainerHigh: Color(0xff393033),
      surfaceContainerHighest: Color(0xff453b3e),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffebf0),
      surfaceTint: Color(0xffffb0cd),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xfffcabc9),
      onPrimaryContainer: Color(0xff20000f),
      secondary: Color(0xffffebf0),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffddb9c4),
      onSecondaryContainer: Color(0xff18060d),
      tertiary: Color(0xffffece2),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffecb892),
      onTertiaryContainer: Color(0xff170700),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff191114),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffebf0),
      outlineVariant: Color(0xffd1bec3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffeedfe2),
      inversePrimary: Color(0xff70344e),
      primaryFixed: Color(0xffffd9e4),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb0cd),
      onPrimaryFixedVariant: Color(0xff2b0015),
      secondaryFixed: Color(0xffffd9e4),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe1bdc8),
      onSecondaryFixedVariant: Color(0xff1e0b13),
      tertiaryFixed: Color(0xffffdcc4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff0bc96),
      onTertiaryFixedVariant: Color(0xff200c00),
      surfaceDim: Color(0xff191114),
      surfaceBright: Color(0xff584d50),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff261d20),
      surfaceContainer: Color(0xff372e31),
      surfaceContainerHigh: Color(0xff43393c),
      surfaceContainerHighest: Color(0xff4e4447),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
