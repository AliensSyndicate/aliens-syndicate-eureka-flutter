import 'package:flutter/material.dart';
import 'ui_color.dart';

abstract final class UiTypography {
  static const title = TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: UiColor.textPrimary,
      ),
      heading = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: UiColor.textPrimary,
      ),
      body = TextStyle(fontSize: 16, height: 1.45, color: UiColor.textPrimary),
      caption = TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: UiColor.textSecondary,
      );
}
