import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_home_bar.dart';
import '../../app/navigation/navigation_router.dart';
import '../../config/config_product.dart';
import '../../controllers/controller_home.dart';
import '../../enums/learning_mode.dart';
import '../../enums/login_context.dart';
import '../../enums/subject_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/auth/model_login_request.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_progress.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../auth/login_bottom_sheet.dart';
import 'widgets/widget_continue_learning_card.dart';
import 'widgets/widget_home_cards_skeleton.dart';
import 'widgets/widget_login_card.dart';
import 'widgets/widget_planet_button.dart';
import 'widgets/widget_recommendation_card.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late final int schoolYear;
  late final Future<List<SubjectContentManifest>> subjects;
  late final Future<ContinueLearningData?> continueLearning;
  late final Future<ContinueLearningData?> recommendation;

  @override
  void initState() {
    super.initState();
    schoolYear = ProductConfig.v1SchoolYear;
    final homeController = HomeController(ServiceRegistry.content);
    subjects = homeController.loadSubjects(schoolYear);
    continueLearning = homeController.loadContinueLearning(schoolYear);
    recommendation = homeController.loadRecommendation(schoolYear);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ServiceRegistry.progress.load();
    final isGuest = !ServiceRegistry.user.isAuthenticated;
    final topSafeArea = MediaQuery.of(context).padding.top;
    final headerHeight = topSafeArea + UiSize.homeAppBarHeight + 72.0;

    return Stack(
      children: [
        // 1. Camada rolável dos planetas que preenche a tela inteira (passando por trás do header)
        Positioned.fill(
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
                  final availableHeight = constraints.maxHeight;
                  final contentHeight = math.max(
                    availableHeight - headerHeight,
                    560.0,
                  );
                  final basePlanetSize = math.min(
                    w * 0.36,
                    contentHeight * 0.22,
                  );

                  final sizePortuguese = basePlanetSize * 1.05;
                  final sizeMathematics = basePlanetSize * 0.92;
                  final sizeScience = basePlanetSize * 1.15;
                  final sizeGeography = basePlanetSize * 0.96;
                  final sizeHistory = basePlanetSize * 1.08;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: headerHeight,
                      bottom: UiSpacing.xxl,
                    ),
                    child: SizedBox(
                      width: w,
                      height: contentHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Português (órbita superior esquerda)
                          if (portuguese != null)
                            Positioned(
                              left: w * 0.05,
                              top: (contentHeight * 0.01) + 20.0,
                              child: PlanetButton(
                                subject: portuguese,
                                size: sizePortuguese,
                                progressText: _progressFraction(
                                  portuguese,
                                  progress,
                                ),
                                animationIndex: 0,
                                onTap: () => _openSubject(portuguese),
                              ),
                            ),

                          // 2. Matemática (órbita média direita)
                          if (mathematics != null)
                            Positioned(
                              left: w * 0.56,
                              top: contentHeight * 0.14,
                              child: PlanetButton(
                                subject: mathematics,
                                size: sizeMathematics,
                                progressText: _progressFraction(
                                  mathematics,
                                  progress,
                                ),
                                animationIndex: 1,
                                onTap: () => _openSubject(mathematics),
                              ),
                            ),

                          // 3. Ciências (órbita central esquerda)
                          if (science != null)
                            Positioned(
                              left: w * 0.16,
                              top: contentHeight * 0.37,
                              child: PlanetButton(
                                subject: science,
                                size: sizeScience,
                                progressText: _progressFraction(
                                  science,
                                  progress,
                                ),
                                animationIndex: 2,
                                onTap: () => _openSubject(science),
                              ),
                            ),

                          // 4. Geografia (órbita média inferior direita)
                          if (geography != null)
                            Positioned(
                              left: w * 0.58,
                              top: contentHeight * 0.55,
                              child: PlanetButton(
                                subject: geography,
                                size: sizeGeography,
                                progressText: _progressFraction(
                                  geography,
                                  progress,
                                ),
                                animationIndex: 3,
                                onTap: () => _openSubject(geography),
                              ),
                            ),

                          // 5. História (órbita inferior central)
                          if (history != null)
                            Positioned(
                              left: w * 0.28,
                              top: contentHeight * 0.74,
                              child: PlanetButton(
                                subject: history,
                                size: sizeHistory,
                                progressText: _progressFraction(
                                  history,
                                  progress,
                                ),
                                animationIndex: 4,
                                onTap: () => _openSubject(history),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // 2. Camada fixa e transparente no topo (AppBar + Carrossel de Cards)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppHomeBar(
                  xp: progress.xp,
                  schoolYear: schoolYear,
                  onXpTap: () => _showValue(
                    AppStrings.xpLabel,
                    AppStrings.xpValue(progress.xp),
                  ),
                  onSchoolYearTap: () => _showValue(
                    AppStrings.turmaLabel,
                    AppStrings.schoolYear(schoolYear),
                  ),
                ),
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([continueLearning, recommendation]),
                  builder: (context, snapshot) {
                    final continueData = snapshot.hasData
                        ? snapshot.data![0] as ContinueLearningData?
                        : null;
                    final recData = snapshot.hasData
                        ? snapshot.data![1] as ContinueLearningData?
                        : null;

                    final hasAnyCard =
                        continueData != null || recData != null || isGuest;
                    if (!hasAnyCard) return const SizedBox.shrink();

                    return Container(
                      height: 72.0,
                      margin: EdgeInsets.zero,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: UiSpacing.pageHorizontal,
                        ),
                        children: [
                          if (isGuest) ...[
                            LoginCard(
                              onTap: () async {
                                final authenticated =
                                    await showLoginBottomSheet(
                                      context,
                                      const LoginRequest(
                                        context: LoginContext.saveProgress,
                                      ),
                                    );
                                if (authenticated && mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                            const SizedBox(width: UiSpacing.sm),
                          ],
                          if (recData != null) ...[
                            RecommendationCard(
                              subject: recData.subject,
                              lesson: recData.lesson,
                              onTap: () async {
                                await context.pushNamed(
                                  AppRoute.lesson,
                                  extra: LessonRouteArguments(
                                    lesson: recData.lesson,
                                    mode: LearningMode.journey,
                                  ),
                                );
                                if (mounted) setState(() {});
                              },
                            ),
                            const SizedBox(width: UiSpacing.sm),
                          ],
                          if (continueData != null)
                            ContinueLearningCard(
                              subject: continueData.subject,
                              lesson: continueData.lesson,
                              onTap: () async {
                                await context.pushNamed(
                                  AppRoute.lesson,
                                  extra: LessonRouteArguments(
                                    lesson: continueData.lesson,
                                    mode: LearningMode.journey,
                                  ),
                                );
                                if (mounted) setState(() {});
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
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
      extra: SubjectRouteArguments(subject: subject, schoolYear: schoolYear),
    );
    if (mounted) setState(() {});
  }

  String _progressFraction(
    SubjectContentManifest subject,
    UserProgress progress,
  ) {
    final lessons = subject.availableLessonsForYear(schoolYear);
    if (lessons.isEmpty) return '0/0';
    final completed = lessons
        .where((l) => progress.completedLessonIds.contains(l.id))
        .length;
    return AppStrings.progressRatio(completed, lessons.length);
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
