import 'package:eureka/ui/ui_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

abstract final class UiIcon {
  static Widget build({required String assetName, double size = UiSize.icon}) {
    return SvgPicture.asset(
      'assets/icons/$assetName.svg',
      width: size,
      height: size,
    );
  }

  static Widget home({double size = UiSize.icon}) =>
      build(assetName: 'home', size: size);
  static Widget social({double size = UiSize.icon}) =>
      build(assetName: 'social', size: size);
  static Widget search({double size = UiSize.icon}) =>
      build(assetName: 'search', size: size);
  static Widget simulated({double size = UiSize.icon}) =>
      build(assetName: 'simulated', size: size);
  static Widget profile({double size = UiSize.icon}) =>
      build(assetName: 'profile', size: size);
  static Widget diamontXp({double size = UiSize.icon}) =>
      build(assetName: 'diamont_xp', size: size);

  static Widget subjectPortuguese({double size = UiSize.icon}) =>
      build(assetName: 'subject_portuguese', size: size);
  static Widget subjectMath({double size = UiSize.icon}) =>
      build(assetName: 'subject_math', size: size);
  static Widget subjectGeography({double size = UiSize.icon}) =>
      build(assetName: 'subject_geography', size: size);
  static Widget subjectChemistry({double size = UiSize.icon}) =>
      build(assetName: 'subject_chemistry', size: size);
  static Widget subjectBiology({double size = UiSize.icon}) =>
      build(assetName: 'subject_biology', size: size);
  static Widget subjectPhysics({double size = UiSize.icon}) =>
      build(assetName: 'subject_physics', size: size);
  static Widget subjectHistory({double size = UiSize.icon}) =>
      build(assetName: 'subject_history', size: size);
  static Widget subjectEnglish({double size = UiSize.icon}) =>
      build(assetName: 'subject_english', size: size);
  static Widget subjectSpanish({double size = UiSize.icon}) =>
      build(assetName: 'subject_spanish', size: size);

  static Widget backpackGreen({double size = UiSize.icon}) =>
      build(assetName: 'backpack_green', size: size);
  static Widget backpackLightGreen({double size = UiSize.icon}) =>
      build(assetName: 'backpack_light_green', size: size);
  static Widget backpackYellow({double size = UiSize.icon}) =>
      build(assetName: 'backpack_yellow', size: size);
  static Widget backpackOrange({double size = UiSize.icon}) =>
      build(assetName: 'backpack_orange', size: size);
  static Widget backpackRed({double size = UiSize.icon}) =>
      build(assetName: 'backpack_red', size: size);
  static Widget backpackPink({double size = UiSize.icon}) =>
      build(assetName: 'backpack_pink', size: size);
  static Widget backpackPurple({double size = UiSize.icon}) =>
      build(assetName: 'backpack_purple', size: size);
  static Widget backpackIndigo({double size = UiSize.icon}) =>
      build(assetName: 'backpack_indigo', size: size);
  static Widget backpackBlue({double size = UiSize.icon}) =>
      build(assetName: 'backpack_blue', size: size);
  static Widget backpackTeal({double size = UiSize.icon}) =>
      build(assetName: 'backpack_teal', size: size);
  static Widget backpackDarkSlate({double size = UiSize.icon}) =>
      build(assetName: 'backpack_dark_slate', size: size);

  static Widget backpack1Ef1({double size = UiSize.icon}) =>
      build(assetName: 'backpack_1_ef1', size: size);
  static Widget backpack2Ef1({double size = UiSize.icon}) =>
      build(assetName: 'backpack_2_ef1', size: size);
  static Widget backpack3Ef1({double size = UiSize.icon}) =>
      build(assetName: 'backpack_3_ef1', size: size);
  static Widget backpack4Ef1({double size = UiSize.icon}) =>
      build(assetName: 'backpack_4_ef1', size: size);
  static Widget backpack5Ef1({double size = UiSize.icon}) =>
      build(assetName: 'backpack_5_ef1', size: size);
  static Widget backpack6Ef2({double size = UiSize.icon}) =>
      build(assetName: 'backpack_6_ef2', size: size);
  static Widget backpack7Ef2({double size = UiSize.icon}) =>
      build(assetName: 'backpack_7_ef2', size: size);
  static Widget backpack8Ef2({double size = UiSize.icon}) =>
      build(assetName: 'backpack_8_ef2', size: size);
  static Widget backpack9Ef2({double size = UiSize.icon}) =>
      build(assetName: 'backpack_9_ef2', size: size);
  static Widget backpack1Em({double size = UiSize.icon}) =>
      build(assetName: 'backpack_1_em', size: size);
  static Widget backpack2Em({double size = UiSize.icon}) =>
      build(assetName: 'backpack_2_em', size: size);
  static Widget backpack3Em({double size = UiSize.icon}) =>
      build(assetName: 'backpack_3_em', size: size);
}
