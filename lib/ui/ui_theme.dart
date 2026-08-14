import 'package:flutter/material.dart';
import 'ui_color.dart';
import 'ui_radius.dart';
import 'ui_typography.dart';
import 'ui_size.dart';

abstract final class UiTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: UiColor.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: UiColor.primary,
      surface: UiColor.surface,
    ),
    textTheme: const TextTheme(
      titleLarge: UiTypography.title,
      titleMedium: UiTypography.heading,
      bodyLarge: UiTypography.body,
    ),
    cardTheme: CardThemeData(
      color: UiColor.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiRadius.md),
        side: const BorderSide(color: UiColor.outline),
      ),
    ),
    filledButtonTheme: const FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size.fromHeight(UiSize.touchTarget),
        ),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 72,
      backgroundColor: UiColor.surface,
      indicatorColor: Color(0x226C5CE7),
    ),
  );
}
