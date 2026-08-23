import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../services/service_registry.dart';
import '../../../services/service_scoring.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LessonProgressCard extends StatefulWidget {
  const LessonProgressCard({
    required this.lesson,
    required this.color,
    required this.lessonIndex,
    required this.totalLessons,
    required this.isCompleted,
    required this.onTap,
    super.key,
  });

  final Lesson lesson;
  final Color color;
  final int lessonIndex;
  final int totalLessons;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  State<LessonProgressCard> createState() => _LessonProgressCardState();
}

class _LessonProgressCardState extends State<LessonProgressCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnim;
  late final ScrollController _scrollController;
  Timer? _marqueeTimer;
  bool _needsMarquee = false;

  static const double _progressBarHeight = 20.0;
  static const double _trackOpacity = 0.18;
  static const int _marqueeDelay = 1500;
  static const double _marqueeSpeed = 0.8;

  @override
  bool get wantKeepAlive => true;

  int get _difficultyLevel {
    if (widget.lesson.questions.isEmpty) return 1;
    final maxDiff = widget.lesson.questions
        .map((q) => q.difficulty)
        .fold<int>(1, math.max);
    return maxDiff.clamp(1, 5);
  }

  String get _xpText {
    final session = ServiceRegistry.progress.loadLessonSession(
      widget.lesson.id,
    );
    final scoring = ScoringService();
    final hasStarted =
        session.currentPage > 0 ||
        session.questionIds.isNotEmpty ||
        session.answers.isNotEmpty ||
        session.results.isNotEmpty ||
        session.completed ||
        widget.isCompleted;

    if (widget.isCompleted) {
      final result = ServiceRegistry.progress.loadLatestActivityResult(
        widget.lesson.id,
      );
      final earned =
          result?.earnedXp ??
          scoring.calculateJourneyXpFromResults(session.results.values);
      return AppStrings.earnedXpGain(earned);
    }

    if (hasStarted) {
      final earned = scoring.calculateJourneyXpFromResults(
        session.results.values,
      );
      return AppStrings.earnedXpGain(earned);
    }

    return AppStrings.earnUpToXp(ScoringService.maximumJourneyLessonXp);
  }

  double _calculateProgress() {
    if (widget.isCompleted) return 1.0;
    final session = ServiceRegistry.progress.loadLessonSession(
      widget.lesson.id,
    );
    if (session.completed) return 1.0;
    final total = session.questionIds.isNotEmpty
        ? session.questionIds.length
        : (widget.lesson.practiceQuestions.isNotEmpty
              ? (widget.lesson.practiceQuestions.length > 5
                    ? 5
                    : widget.lesson.practiceQuestions.length)
              : (widget.lesson.questions.isNotEmpty
                    ? (widget.lesson.questions.length > 5
                          ? 5
                          : widget.lesson.questions.length)
                    : 1));
    final answered = session.results.length;
    if (total == 0 || answered == 0) return 0.0;
    return (answered / total).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final target = _calculateProgress();
    _progressAnim = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    _progressController.forward();

    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkMarquee());
  }

  void _checkMarquee() {
    if (!mounted) return;
    final maxWidth = _scrollController.position.maxScrollExtent;
    if (maxWidth > 0 && !_needsMarquee) {
      setState(() => _needsMarquee = true);
      _startMarquee();
    }
  }

  void _startMarquee() {
    _marqueeTimer = Timer(const Duration(milliseconds: _marqueeDelay), () {
      if (!mounted || !_scrollController.hasClients) return;
      _animateMarquee();
    });
  }

  void _animateMarquee() {
    if (!mounted || !_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    _scrollController
        .animateTo(
          max,
          duration: Duration(milliseconds: (max / _marqueeSpeed * 16).round()),
          curve: Curves.linear,
        )
        .then((_) {
          if (!mounted) return;
          _marqueeTimer = Timer(const Duration(milliseconds: 800), () {
            if (!mounted || !_scrollController.hasClients) return;
            _scrollController.jumpTo(0);
            _marqueeTimer = Timer(
              const Duration(milliseconds: _marqueeDelay),
              _animateMarquee,
            );
          });
        });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scrollController.dispose();
    _marqueeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Semantics(
      button: true,
      label: AppStrings.lessonSemantics(
        widget.lesson.title,
        widget.isCompleted,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.lg),
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MarqueeText(
                    text: widget.lesson.title,
                    scrollController: _scrollController,
                    isCompleted: widget.isCompleted,
                    color: widget.color,
                  ),
                  const SizedBox(height: UiSpacing.xxs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.difficultyLevelName(_difficultyLevel),
                        style: UiText.p.copyWith(
                          color: UiColor.forDifficulty(_difficultyLevel),
                        ),
                      ),
                      Text(
                        _xpText,
                        style: UiText.p.copyWith(
                          color: UiColor.xp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UiSpacing.xs),
                  SizedBox(
                    height: _progressBarHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(UiRadius.pill),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: ColoredBox(
                              color: widget.color.withValues(
                                alpha: _trackOpacity,
                              ),
                            ),
                          ),
                          if (_progressAnim.value > 0)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnim.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: widget.color,
                                    borderRadius: BorderRadius.circular(
                                      UiRadius.pill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Center(
                            child: Text(
                              AppStrings.percent(
                                (_progressAnim.value * 100).round(),
                              ),
                              style: UiText.p.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _progressAnim.value > 0.4
                                    ? Colors.white
                                    : widget.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarqueeText extends StatelessWidget {
  const _MarqueeText({
    required this.text,
    required this.scrollController,
    required this.isCompleted,
    required this.color,
  });

  final String text;
  final ScrollController scrollController;
  final bool isCompleted;
  final Color color;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(text, maxLines: 1, softWrap: false, style: UiText.h6),
    ),
  );
}
