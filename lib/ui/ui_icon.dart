import 'package:eureka/ui/ui_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

abstract final class UiIcon {
  static Widget build({
    required String assetName,
    double size = UiSize.icon,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) {
    final double? finalWidth = onlyHeight ? null : size;
    final double? finalHeight = onlyWidth ? null : size;

    return SizedBox(
      width: finalWidth,
      height: finalHeight,
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/$assetName.svg',
          width: finalWidth,
          height: finalHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  static Widget logo({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'logo',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget home({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'home',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget social({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'social',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget search({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'search',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget simulated({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'simulated',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget profile({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'profile',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget diamontXp({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'diamont_xp',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectPortuguese({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_portuguese',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectMath({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_math',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectGeography({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_geography',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectScience({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_science',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectBiology({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_biology',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectPhysics({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_physics',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectHistory({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_history',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectEnglish({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_english',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget subjectSpanish({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'subject_spanish',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack1Ef1({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_1_ef1',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack2Ef1({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_2_ef1',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack3Ef1({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_3_ef1',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack4Ef1({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_4_ef1',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack5Ef1({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_5_ef1',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack6Ef2({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_6_ef2',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack7Ef2({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_7_ef2',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack8Ef2({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_8_ef2',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack9Ef2({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_9_ef2',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack1Em({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_1_em',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack2Em({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_2_em',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );

  static Widget backpack3Em({
    double size = UiSize.iconNavigation,
    bool onlyWidth = false,
    bool onlyHeight = false,
  }) => build(
    assetName: 'backpack_3_em',
    size: size,
    onlyWidth: onlyWidth,
    onlyHeight: onlyHeight,
  );
}
