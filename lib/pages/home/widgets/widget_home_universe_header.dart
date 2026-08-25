import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import 'widget_planet_orbit_motion.dart';

class HomeUniverseHeader extends StatelessWidget {
  const HomeUniverseHeader({
    required this.xp,
    required this.schoolYear,
    required this.onXpTap,
    required this.onSchoolYearTap,
    this.hasNewSchoolYears = false,
    this.reducedMotion = false,
    super.key,
  });

  static const height = 144.0;

  final int xp;
  final int schoolYear;
  final VoidCallback onXpTap;
  final VoidCallback onSchoolYearTap;
  final bool hasNewSchoolYears;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('home-universe-header'),
    height: height,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: UiSpacing.pageHorizontal,
          top: 8,
          child: PlanetOrbitMotion(
            animationIndex: 10,
            enabled: !reducedMotion,
            child: _UniverseBadge(
              key: const ValueKey('home-xp-button'),
              text: AppStrings.homeXpValue(xp),
              semanticLabel: AppStrings.xpLabel,
              icon: UiIcon.diamontXp(size: UiSize.iconMd),
              onTap: onXpTap,
            ),
          ),
        ),
        Positioned(
          right: UiSpacing.pageHorizontal,
          top: 18,
          child: PlanetOrbitMotion(
            animationIndex: 11,
            enabled: !reducedMotion,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _UniverseBadge(
                  key: const ValueKey('home-school-year-button'),
                  text: AppStrings.homeSchoolYear(schoolYear),
                  semanticLabel: AppStrings.turmaLabel,
                  icon: UiIcon.backpackForYear(schoolYear, size: UiSize.iconMd),
                  onTap: onSchoolYearTap,
                ),
                if (hasNewSchoolYears)
                  Positioned(
                    top: 4,
                    right: -6,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: UiColor.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.42),
          child: PlanetOrbitMotion(
            animationIndex: 12,
            enabled: !reducedMotion,
            child: Semantics(
              key: const ValueKey('home-universe-logo'),
              label: AppStrings.appName,
              image: true,
              child: UiIcon.logo(size: 36),
            ),
          ),
        ),
      ],
    ),
  );
}

class _UniverseBadge extends StatelessWidget {
  const _UniverseBadge({
    required this.text,
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String text;
  final String semanticLabel;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    value: text,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(UiRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiRadius.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: UiSize.touchTarget,
            minHeight: UiSize.touchTarget,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: UiSpacing.xxs),
              Text(
                text,
                style: UiText.h6.copyWith(
                  color: UiColor.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
