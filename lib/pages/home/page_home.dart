import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/show_school_year_sheet.dart';
import '../../app/navigation/navigation_router.dart';
import '../../config/config_product.dart';
import '../../controllers/controller_home.dart';
import '../../enums/learning_mode.dart';
import '../../enums/login_context.dart';
import '../../enums/subject_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/auth/model_login_request.dart';
import '../../models/content/model_content_manifest.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import '../auth/login_bottom_sheet.dart';
import '../subject/page_subject.dart';
import 'widgets/widget_continue_learning_card.dart';
import 'widgets/widget_home_cards_skeleton.dart';
import 'widgets/widget_home_universe_header.dart';
import 'widgets/widget_login_card.dart';
import 'widgets/widget_planet_button.dart';
import 'widgets/widget_recommendation_card.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  static const _quickActionsOrbitHeight = 188.0;
  static const _subjectOrbitCompression = 0.94;

  late int schoolYear;
  late Future<List<SubjectContentManifest>> subjects;
  late Future<ContinueLearningData?> continueLearning;
  late Future<ContinueLearningData?> recommendation;

  @override
  void initState() {
    super.initState();
    schoolYear = ProductConfig.v1SchoolYear;
    _loadData(schoolYear);
  }

  void _loadData(int year) {
    final homeController = HomeController(ServiceRegistry.content);
    subjects = homeController.loadSubjects(year);
    continueLearning = homeController.loadContinueLearning(year);
    recommendation = homeController.loadRecommendation(year);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ServiceRegistry.progress.load();
    final isGuest = !ServiceRegistry.user.isAuthenticated;
    final reducedMotion = ServiceRegistry.preferences.load().reducedMotion;
    final topSafeArea = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
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
              final biology = _findSubject(items, SubjectType.biology, 5);
              final physics = _findSubject(items, SubjectType.physics, 6);
              final chemistry = _findSubject(items, SubjectType.chemistry, 7);
              final philosophy = _findSubject(items, SubjectType.philosophy, 8);
              final sociology = _findSubject(items, SubjectType.sociology, 9);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final availableHeight = constraints.maxHeight;
                  final basePlanetSize = math.min(w * 0.30, 140.0);

                  final sizePortuguese = basePlanetSize * 1.05;
                  final sizeMathematics = basePlanetSize * 0.92;
                  final sizeScience = basePlanetSize * 1.15;
                  final sizeGeography = basePlanetSize * 0.96;
                  final sizeHistory = basePlanetSize * 1.08;
                  final sizeBiology = basePlanetSize * 1.02;
                  final sizePhysics = basePlanetSize * 0.94;
                  final sizeChemistry = basePlanetSize * 1.10;
                  final sizePhilosophy = basePlanetSize * 0.98;
                  final sizeSociology = basePlanetSize * 1.06;

                  double planetSize(SubjectType type) => switch (type) {
                    SubjectType.portuguese => sizePortuguese,
                    SubjectType.mathematics => sizeMathematics,
                    SubjectType.science => sizeScience,
                    SubjectType.geography => sizeGeography,
                    SubjectType.history => sizeHistory,
                    SubjectType.biology => sizeBiology,
                    SubjectType.physics => sizePhysics,
                    SubjectType.chemistry => sizeChemistry,
                    SubjectType.philosophy => sizePhilosophy,
                    SubjectType.sociology => sizeSociology,
                  };

                  double orbitTop(SubjectType type) =>
                      HomeUniverseHeader.height +
                      _quickActionsOrbitHeight +
                      _subjectOrbitCompression *
                          switch (type) {
                            SubjectType.portuguese => 20.4,
                            SubjectType.mathematics => 104.0,
                            SubjectType.science => 228.8,
                            SubjectType.geography => 353.6,
                            SubjectType.history => 468.0,
                            SubjectType.biology => 561.6,
                            SubjectType.physics => 665.6,
                            SubjectType.chemistry => 728.0,
                            SubjectType.philosophy => 852.8,
                            SubjectType.sociology => 915.2,
                          };

                  final planetsBottom = items.fold<double>(0, (bottom, item) {
                    return math.max(
                      bottom,
                      orbitTop(item.type) + planetSize(item.type),
                    );
                  });
                  final contentHeight = math.max(
                    availableHeight - topSafeArea,
                    planetsBottom + UiSpacing.xl,
                  );

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: topSafeArea,
                      bottom: UiSpacing.xxl,
                    ),
                    child: SizedBox(
                      key: const ValueKey('home-planets-orbit'),
                      width: w,
                      height: contentHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: HomeUniverseHeader.height,
                            child: HomeUniverseHeader(
                              xp: progress.xp,
                              schoolYear: schoolYear,
                              onXpTap: () => _showValue(
                                AppStrings.xpLabel,
                                AppStrings.xpValue(progress.xp),
                              ),
                              onSchoolYearTap: _onSchoolYearTap,
                              hasNewSchoolYears:
                                  ProductConfig.availableSchoolYears.length > 1,
                              reducedMotion: reducedMotion,
                            ),
                          ),
                          Positioned(
                            top: HomeUniverseHeader.height,
                            left: 0,
                            right: 0,
                            height: _quickActionsOrbitHeight,
                            child: _buildQuickActions(isGuest),
                          ),
                          // 1. Português (órbita superior esquerda)
                          if (portuguese != null)
                            Positioned(
                              left: w * 0.07,
                              top: orbitTop(SubjectType.portuguese),
                              child: PlanetButton(
                                subject: portuguese,
                                size: sizePortuguese,
                                progressText: _progressFraction(portuguese),
                                animationIndex: 0,
                                onTap: () => _openSubject(portuguese),
                              ),
                            ),

                          // 2. Matemática (órbita superior direita)
                          if (mathematics != null)
                            Positioned(
                              left: w * 0.60,
                              top: orbitTop(SubjectType.mathematics),
                              child: PlanetButton(
                                subject: mathematics,
                                size: sizeMathematics,
                                progressText: _progressFraction(mathematics),
                                animationIndex: 1,
                                onTap: () => _openSubject(mathematics),
                              ),
                            ),

                          // 3. Ciências (órbita interna esquerda)
                          if (science != null)
                            Positioned(
                              left: w * 0.18,
                              top: orbitTop(SubjectType.science),
                              child: PlanetButton(
                                subject: science,
                                size: sizeScience,
                                progressText: _progressFraction(science),
                                animationIndex: 2,
                                onTap: () => _openSubject(science),
                              ),
                            ),

                          // 4. Geografia (órbita externa direita)
                          if (geography != null)
                            Positioned(
                              left: w * 0.64,
                              top: orbitTop(SubjectType.geography),
                              child: PlanetButton(
                                subject: geography,
                                size: sizeGeography,
                                progressText: _progressFraction(geography),
                                animationIndex: 3,
                                onTap: () => _openSubject(geography),
                              ),
                            ),

                          // 5. História (órbita externa esquerda)
                          if (history != null)
                            Positioned(
                              left: w * 0.06,
                              top: orbitTop(SubjectType.history),
                              child: PlanetButton(
                                subject: history,
                                size: sizeHistory,
                                progressText: _progressFraction(history),
                                animationIndex: 4,
                                onTap: () => _openSubject(history),
                              ),
                            ),

                          // 6. Biologia (órbita interna direita)
                          if (biology != null)
                            Positioned(
                              left: w * 0.55,
                              top: orbitTop(SubjectType.biology),
                              child: PlanetButton(
                                subject: biology,
                                size: sizeBiology,
                                progressText: _progressFraction(biology),
                                animationIndex: 5,
                                onTap: () => _openSubject(biology),
                              ),
                            ),

                          // 7. Física (órbita central esquerda)
                          if (physics != null)
                            Positioned(
                              left: w * 0.25,
                              top: orbitTop(SubjectType.physics),
                              child: PlanetButton(
                                subject: physics,
                                size: sizePhysics,
                                progressText: _progressFraction(physics),
                                animationIndex: 6,
                                onTap: () => _openSubject(physics),
                              ),
                            ),

                          // 8. Química (órbita externa direita)
                          if (chemistry != null)
                            Positioned(
                              left: w * 0.62,
                              top: orbitTop(SubjectType.chemistry),
                              child: PlanetButton(
                                subject: chemistry,
                                size: sizeChemistry,
                                progressText: _progressFraction(chemistry),
                                animationIndex: 7,
                                onTap: () => _openSubject(chemistry),
                              ),
                            ),

                          // 9. Filosofia (órbita final esquerda)
                          if (philosophy != null)
                            Positioned(
                              left: w * 0.06,
                              top: orbitTop(SubjectType.philosophy),
                              child: PlanetButton(
                                subject: philosophy,
                                size: sizePhilosophy,
                                progressText: _progressFraction(philosophy),
                                animationIndex: 8,
                                onTap: () => _openSubject(philosophy),
                              ),
                            ),

                          // 10. Sociologia (órbita final interna)
                          if (sociology != null)
                            Positioned(
                              left: w * 0.48,
                              top: orbitTop(SubjectType.sociology),
                              child: PlanetButton(
                                subject: sociology,
                                size: sizeSociology,
                                progressText: _progressFraction(sociology),
                                animationIndex: 9,
                                onTap: () => _openSubject(sociology),
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
      ],
    );
  }

  Widget _buildQuickActions(bool isGuest) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([continueLearning, recommendation]),
      builder: (context, snapshot) {
        final continueData = snapshot.hasData
            ? snapshot.data![0] as ContinueLearningData?
            : null;
        final recData = snapshot.hasData
            ? snapshot.data![1] as ContinueLearningData?
            : null;

        final hasAnyAction = continueData != null || recData != null || isGuest;
        if (!hasAnyAction) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              if (recData != null)
                Positioned(
                  left: constraints.maxWidth * 0.08,
                  top: 8,
                  child: RecommendationCard(
                    lesson: recData.lesson,
                    onTap: () => _showLessonActionSheet(
                      title: AppStrings.recommendationTitle,
                      data: recData,
                      confirmationLabel: AppStrings.startActivity,
                    ),
                  ),
                ),
              if (continueData != null)
                Positioned(
                  right: constraints.maxWidth * 0.08,
                  top: 48,
                  child: ContinueLearningCard(
                    lesson: continueData.lesson,
                    onTap: () => _showLessonActionSheet(
                      title: AppStrings.continueTitle,
                      data: continueData,
                      confirmationLabel: AppStrings.continueLabel,
                    ),
                  ),
                ),
              if (isGuest)
                Positioned(
                  left: constraints.maxWidth * 0.08,
                  top: 108,
                  child: LoginCard(
                    onTap: () async {
                      final authenticated = await showLoginBottomSheet(
                        context,
                        const LoginRequest(context: LoginContext.saveProgress),
                      );
                      if (authenticated && mounted) setState(() {});
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLessonActionSheet({
    required String title,
    required ContinueLearningData data,
    required String confirmationLabel,
  }) async {
    final subjectColor = UiColor.forSubject(data.subject.type);
    final confirmed = await AppBottomSheet.show<bool>(
      context,
      title: title,
      titleColor: subjectColor,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.subject.title,
            style: UiText.h6.copyWith(color: subjectColor),
          ),
          const SizedBox(height: UiSpacing.xs),
          Text(data.lesson.title, style: UiText.p),
          if (data.lesson.summary.trim().isNotEmpty) ...[
            const SizedBox(height: UiSpacing.sm),
            Text(data.lesson.summary, style: UiText.p),
          ],
        ],
      ),
      actions: [
        Builder(
          builder: (sheetContext) => AppButton(
            label: confirmationLabel,
            color: subjectColor,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;

    await context.pushNamed(
      AppRoute.lesson,
      extra: LessonRouteArguments(
        lesson: data.lesson,
        mode: LearningMode.journey,
      ),
    );
    if (mounted) setState(() {});
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
    await showSubjectSheet(context, subject: subject, schoolYear: schoolYear);
    if (mounted) setState(() {});
  }

  String _progressFraction(SubjectContentManifest subject) {
    final lessons = subject.availableLessonsForYear(schoolYear);
    if (lessons.isEmpty) return AppStrings.planetProgressRatio(0, 0);
    final activityProgress = ServiceRegistry.progress.activityProgress(lessons);
    return AppStrings.planetProgressRatio(
      activityProgress.completed,
      activityProgress.total,
    );
  }

  Future<void> _onSchoolYearTap() async {
    final selected = await showSchoolYearSheet(
      context,
      currentYear: schoolYear,
      availableYears: ProductConfig.availableSchoolYears,
    );
    if (selected != null && selected != schoolYear && mounted) {
      setState(() {
        schoolYear = selected;
        _loadData(selected);
      });
    }
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
