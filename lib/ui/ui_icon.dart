import 'package:eureka/ui/ui_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';

abstract final class UiIcon {
  static Widget huge({
    required List<List<dynamic>> icon,
    double size = UiSize.icon,
    Color? color,
  }) => HugeIcon(icon: icon, size: size, color: color, strokeWidth: 2.5);

  // ações gerais
  static Widget back({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedArrowLeft02, size: size, color: color);
  static Widget close({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedCancel01, size: size, color: color);
  static Widget share({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedShare01, size: size, color: color);
  static Widget report({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedFlag02, size: size, color: color);
  static Widget search({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedSearch01, size: size, color: color);
  static Widget next({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedArrowRight01, size: size, color: color);
  static Widget play({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedVolumeHigh, size: size, color: color);
  static Widget pause({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedVolumeMute02, size: size, color: color);
  static Widget correct({double size = UiSize.icon, Color? color}) => huge(
    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
    size: size,
    color: color,
  );
  static Widget incorrect({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedCancelCircle, size: size, color: color);
  static Widget check({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedTick02, size: size, color: color);
  static Widget drag({double size = UiSize.icon, Color? color}) => huge(
    icon: HugeIcons.strokeRoundedDragDropVertical,
    size: size,
    color: color,
  );
  static Widget trophy({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedChampion, size: size, color: color);
  static Widget user({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedUserCircle, size: size, color: color);
  static Widget flash({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedFlash, size: size, color: color);
  static Widget timer({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedTimer02, size: size, color: color);
  static Widget star({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedStar, size: size, color: color);
  static Widget sparkles({double size = UiSize.icon, Color? color}) =>
      huge(icon: HugeIcons.strokeRoundedSparkles, size: size, color: color);

  static Widget build({required String assetName, double size = UiSize.icon}) {
    return SizedBox(
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/$assetName.svg',
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // componentes
  static Widget logo({double size = UiSize.iconNavigation}) =>
      build(assetName: 'logo', size: size);
  static Widget diamontXp({double size = UiSize.iconNavigation}) =>
      build(assetName: 'diamont_xp', size: size);

  // navegação principal
  static Widget navHome({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_home', size: size);
  static Widget navHomeSelected({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_home_selected', size: size);

  static Widget navSocial({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_social', size: size);
  static Widget navSocialSelected({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_social_selected', size: size);

  static Widget navSearch({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_search', size: size);
  static Widget navSearchSelected({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_search_selected', size: size);

  static Widget navSimulated({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_simulated', size: size);
  static Widget navSimulatedSelected({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_simulated_selected', size: size);

  static Widget navProfile({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_profile', size: size);
  static Widget navProfileSelected({double size = UiSize.iconNavigation}) =>
      build(assetName: 'nav_profile_selected', size: size);

  // materias
  static Widget subjectPortuguese({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_portuguese', size: size);
  static Widget subjectMath({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_math', size: size);
  static Widget subjectGeography({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_geography', size: size);
  static Widget subjectScience({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_science', size: size);
  static Widget subjectBiology({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_biology', size: size);
  static Widget subjectPhysics({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_physics', size: size);
  static Widget subjectHistory({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_history', size: size);
  static Widget subjectEnglish({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_english', size: size);
  static Widget subjectSpanish({double size = UiSize.iconNavigation}) =>
      build(assetName: 'subject_spanish', size: size);

  // ano letivo
  static Widget backpack1Ef1({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_1_ef1', size: size);
  static Widget backpack2Ef1({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_2_ef1', size: size);
  static Widget backpack3Ef1({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_3_ef1', size: size);
  static Widget backpack4Ef1({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_4_ef1', size: size);
  static Widget backpack5Ef1({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_5_ef1', size: size);
  static Widget backpack6Ef2({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_6_ef2', size: size);
  static Widget backpack7E2({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_7_ef2', size: size);
  static Widget backpack8Ef2({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_8_ef2', size: size);
  static Widget backpack9Ef2({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_9_ef2', size: size);
  static Widget backpack1Em({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_1_em', size: size);
  static Widget backpack2Em({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_2_em', size: size);
  static Widget backpack3Em({double size = UiSize.iconNavigation}) =>
      build(assetName: 'backpack_3_em', size: size);
}
