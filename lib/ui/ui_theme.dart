import 'package:flutter/material.dart';
import 'ui_color.dart';
import 'ui_radius.dart';
import 'ui_size.dart';
import 'ui_bottom_sheet.dart';
import 'ui_text.dart';

abstract final class UiTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: UiText.fontFamily,
    scaffoldBackgroundColor: UiColor.background,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: UiColor.primary,
          brightness: Brightness.dark,
          surface: UiColor.surface,
        ).copyWith(
          primary: UiColor.primary,
          secondary: UiColor.secondary,
          error: UiColor.error,
          onPrimary: UiColor.background,
          onSurface: UiColor.textPrimary,
          outline: UiColor.outline,
          surfaceContainer: UiColor.surfaceElevated,
        ),
    textTheme: const TextTheme(
      displayLarge: UiText.h1,
      displayMedium: UiText.h2,
      displaySmall: UiText.h3,
      headlineLarge: UiText.h2,
      headlineMedium: UiText.h3,
      headlineSmall: UiText.h4,
      titleLarge: UiText.h3,
      titleMedium: UiText.h5,
      titleSmall: UiText.h6,
      bodyLarge: UiText.p,
      bodyMedium: UiText.p,
      bodySmall: UiText.label,
      labelLarge: UiText.label,
      labelMedium: UiText.label,
      labelSmall: UiText.label,
    ),
    cardTheme: CardThemeData(
      color: UiColor.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiRadius.card),
        side: const BorderSide(color: UiColor.outline, width: 2),
      ),
    ),
    filledButtonTheme: const FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size.fromHeight(UiSize.touchTarget),
        ),
        overlayColor: WidgetStateProperty.fromMap({
          WidgetState.pressed: Colors.transparent,
        }),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: UiSize.bottomNavigationHeight,
      backgroundColor: UiColor.navigationBackground,
      indicatorColor: UiColor.surfaceElevated,
      labelTextStyle: WidgetStatePropertyAll(UiText.label),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: UiColor.background,
      foregroundColor: UiColor.textPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    dividerColor: UiColor.divider,
    disabledColor: UiColor.textDisabled,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: UiColor.surfaceElevated,
      modalBackgroundColor: UiColor.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UiBottomSheet.radius),
        ),
      ),
      dragHandleColor: UiColor.textSecondary,
      dragHandleSize: Size(
        UiBottomSheet.handleWidth,
        UiBottomSheet.handleHeight,
      ),
    ),
  );
}
