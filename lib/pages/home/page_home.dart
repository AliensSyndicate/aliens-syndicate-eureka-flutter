import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_home_bar.dart';
import '../../app/navigation/navigation_router.dart';
import '../../config/config_product.dart';
import '../../controllers/controller_home.dart';
import '../../enums/subject_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../services/service_registry.dart';
import 'widgets/widget_home_cards_skeleton.dart';
import 'widgets/widget_planet_button.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late final int schoolYear;
  late final Future<List<SubjectContentManifest>> subjects;

  @override
  void initState() {
    super.initState();
    schoolYear = ProductConfig.v1SchoolYear;
    subjects = HomeController(ServiceRegistry.content).loadSubjects(schoolYear);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ServiceRegistry.progress.load();

    return Column(
      children: [
        AppHomeBar(
          xp: progress.xp,
          schoolYear: schoolYear,
          onXpTap: () =>
              _showValue(AppStrings.xpLabel, AppStrings.xpValue(progress.xp)),
          onSchoolYearTap: () => _showValue(
            AppStrings.turmaLabel,
            AppStrings.schoolYear(schoolYear),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<SubjectContentManifest>>(
            future: subjects,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const HomeCardsSkeleton();
              }
              final items = snapshot.data!;
              if (items.isEmpty) return const SizedBox.shrink();

              final portuguese = _findSubject(items, SubjectType.portuguese, 0);
              final mathematics = _findSubject(
                items,
                SubjectType.mathematics,
                1,
              );
              final science = _findSubject(items, SubjectType.science, 2);
              final geography = _findSubject(items, SubjectType.geography, 3);
              final history = _findSubject(items, SubjectType.history, 4);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  final islandSize = math.min(w * 0.38, h * 0.23);
                  final historySize = math.min(w * 0.42, h * 0.25);

                  return SizedBox(
                    width: w,
                    height: h,
                    child: Stack(
                      children: [
                        // 1. Português (topo esquerdo)
                        if (portuguese != null)
                          Positioned(
                            left: w * 0.02,
                            top: h * 0.01,
                            child: PlanetButton(
                              subject: portuguese,
                              size: islandSize,
                              animationIndex: 0,
                              onTap: () => _openSubject(portuguese),
                            ),
                          ),

                        // 2. Matemática (topo direito)
                        if (mathematics != null)
                          Positioned(
                            right: w * 0.02,
                            top: h * 0.07,
                            child: PlanetButton(
                              subject: mathematics,
                              size: islandSize,
                              animationIndex: 1,
                              onTap: () => _openSubject(mathematics),
                            ),
                          ),

                        // 3. Ciências (meio esquerdo)
                        if (science != null)
                          Positioned(
                            left: w * 0.02,
                            top: h * 0.36,
                            child: PlanetButton(
                              subject: science,
                              size: islandSize,
                              animationIndex: 2,
                              onTap: () => _openSubject(science),
                            ),
                          ),

                        // 4. Geografia (meio direito)
                        if (geography != null)
                          Positioned(
                            right: w * 0.02,
                            top: h * 0.40,
                            child: PlanetButton(
                              subject: geography,
                              size: islandSize,
                              animationIndex: 3,
                              onTap: () => _openSubject(geography),
                            ),
                          ),

                        // 5. História (inferior centro)
                        if (history != null)
                          Positioned(
                            left: (w - historySize) / 2,
                            bottom: h * 0.02,
                            child: PlanetButton(
                              subject: history,
                              size: historySize,
                              animationIndex: 4,
                              onTap: () => _openSubject(history),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  SubjectContentManifest? _findSubject(
    List<SubjectContentManifest> items,
    SubjectType type,
    int fallbackIndex,
  ) {
    for (final item in items) {
      if (item.type == type) return item;
    }
    if (fallbackIndex < items.length) return items[fallbackIndex];
    return null;
  }

  Future<void> _openSubject(SubjectContentManifest subject) async {
    await context.pushNamed(
      AppRoute.subject,
      extra: SubjectRouteArguments(
        subject: subject,
        schoolYear: schoolYear,
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showValue(String title, String value) =>
      AppBottomSheet.show<void>(
        context,
        title: title,
        content: Text(value),
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
}
