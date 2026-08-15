import 'package:flutter/material.dart';

import 'ui_color.dart';

abstract final class UiText {
  static const fontFamily = 'SourGummy';
  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 1.05,
    fontWeight: FontWeight.w800,
    color: UiColor.accent,
  );
  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.10,
    fontWeight: FontWeight.w800,
    color: UiColor.accent,
  );
  static const h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: UiColor.accent,
  );
  static const h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.20,
    fontWeight: FontWeight.w700,
    color: UiColor.accent,
  );
  static const h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: UiColor.accent,
  );
  static const h6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.30,
    fontWeight: FontWeight.w600,
    color: UiColor.textPrimary,
  );
  static const p = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: UiColor.textPrimary,
  );
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.20,
    fontWeight: FontWeight.w600,
    letterSpacing: .25,
    color: UiColor.textSecondary,
  );
}
