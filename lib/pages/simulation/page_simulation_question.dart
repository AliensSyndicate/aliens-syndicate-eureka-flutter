import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/navigation/navigation_router.dart';
import '../../controllers/controller_simulation.dart';
import '../../l10n/app_strings.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import '../lesson/widgets/widget_lesson_activity.dart';

class PageSimulationQuestion extends StatefulWidget {
  const PageSimulationQuestion({required this.controller, super.key});
  final SimulationController controller;
  @override
  State<PageSimulationQuestion> createState() => _PageSimulationQuestionState();
}

class _PageSimulationQuestionState extends State<PageSimulationQuestion>
    with WidgetsBindingObserver {
  Timer? _timer;
  late TextEditingController _textController;
  bool _finishing = false;

  SimulationController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTextController();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _tick() {
    if (!mounted || _finishing) return;
    if (controller.session.remainingAt(DateTime.now()) == Duration.zero) {
      _finish(expired: true);
    } else {
      setState(() {});
    }
  }

  void _resetTextController() {
    _textController = TextEditingController(text: controller.currentAnswer);
  }

  Future<void> _goTo(int index) async {
    await controller.goTo(index);
    _textController.dispose();
    _resetTextController();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    final remaining = session.remainingAt(DateTime.now());
    final item = controller.current;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: AppStrings.simulationExit,
            onPressed: _confirmExit,
            icon: UiIcon.close(),
          ),
          title: InkWell(
            onTap: _showQuestionPanel,
            child: Semantics(
              button: true,
              label: AppStrings.simulationOpenQuestionPanel,
              child: Text(
                '${session.currentIndex + 1} de ${session.questions.length}',
                style: UiText.h6,
              ),
            ),
          ),
          actions: [
            Semantics(
              container: true,
              excludeSemantics: true,
              label: AppStrings.remainingTimeSemantics(remaining),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.md),
                child: Center(
                  child: Text(_formatDuration(remaining), style: UiText.h6),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: LessonActivity(
                    key: ValueKey(item.question.id),
                    question: item.question,
                    position: session.currentIndex + 1,
                    total: session.questions.length,
                    primaryColor: UiColor.forSubject(item.subject),
                    status: LessonActivityStatus.active,
                    interactionEnabled: true,
                    currentAnswer: controller.currentAnswer,
                    submittedAnswer: null,
                    textController: _textController,
                    onOptionSelected: _answer,
                    onTextChanged: _answer,
                  ),
                ),
              ),
              _BottomActions(
                canGoBack: session.currentIndex > 0,
                hasAnswer: controller.currentAnswer.trim().isNotEmpty,
                isLast: controller.isLast,
                marked: session.reviewQuestionIds.contains(item.question.id),
                onPrevious: () => _goTo(session.currentIndex - 1),
                onReview: () async {
                  await controller.toggleReview();
                  if (mounted) setState(() {});
                },
                onSkip: () => controller.isLast
                    ? _confirmFinish()
                    : _goTo(session.currentIndex + 1),
                onNext: () => controller.isLast
                    ? _confirmFinish()
                    : _goTo(session.currentIndex + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _answer(String value) async {
    await controller.answer(value);
    if (mounted) setState(() {});
  }

  Future<void> _showQuestionPanel() => AppBottomSheet.show<void>(
    context,
    title: AppStrings.simulationQuestions,
    content: Wrap(
      spacing: UiSpacing.xs,
      runSpacing: UiSpacing.xs,
      children: controller.session.questions.indexed.map((entry) {
        final index = entry.$1;
        final question = entry.$2.question;
        final answered = controller.session.answers.containsKey(question.id);
        final marked = controller.session.reviewQuestionIds.contains(
          question.id,
        );
        final current = index == controller.session.currentIndex;
        return Semantics(
          label: AppStrings.questionState(index + 1, answered, marked, current),
          button: true,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _goTo(index);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(UiSize.touchTarget, UiSize.touchTarget),
              side: BorderSide(
                color: current
                    ? UiColor.accent
                    : marked
                    ? UiColor.warning
                    : answered
                    ? UiColor.success
                    : UiColor.outline,
                width: current ? 3 : 1.5,
              ),
            ),
            child: Text(marked ? '${index + 1} •' : '${index + 1}'),
          ),
        );
      }).toList(),
    ),
  );

  Future<void> _confirmExit() => AppBottomSheet.show<void>(
    context,
    title: AppStrings.simulationExitTitle,
    content: const Text(AppStrings.simulationExitDescription),
    actions: [
      AppButton(
        label: AppStrings.simulationContinue,
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
          await controller.abandon();
          if (mounted) context.pop();
        },
        child: const Text(AppStrings.simulationExit),
      ),
    ],
  );

  Future<void> _confirmFinish() {
    final unanswered = controller.unanswered;
    return AppBottomSheet.show<void>(
      context,
      title: AppStrings.simulationFinishTitle,
      content: Text(
        unanswered == 0
            ? AppStrings.simulationFinishDescription
            : AppStrings.unansweredWarning(unanswered),
      ),
      actions: [
        if (unanswered > 0)
          AppButton(
            label: AppStrings.simulationReview,
            onPressed: () => Navigator.pop(context),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _finish();
          },
          child: Text(
            unanswered > 0
                ? AppStrings.simulationFinishAnyway
                : AppStrings.finish,
          ),
        ),
      ],
    );
  }

  Future<void> _finish({bool expired = false}) async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    final result = await controller.complete(expired: expired);
    if (!mounted) return;
    context.pushReplacementNamed(
      AppRoute.simulationResult,
      extra: SimulationResultRouteArguments(
        controller: controller,
        result: result,
        expired: expired,
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.canGoBack,
    required this.hasAnswer,
    required this.isLast,
    required this.marked,
    required this.onPrevious,
    required this.onReview,
    required this.onSkip,
    required this.onNext,
  });
  final bool canGoBack;
  final bool hasAnswer;
  final bool isLast;
  final bool marked;
  final VoidCallback onPrevious;
  final VoidCallback onReview;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(UiSpacing.md),
    decoration: const BoxDecoration(
      color: UiColor.background,
      border: Border(top: BorderSide(color: UiColor.divider)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: canGoBack ? onPrevious : null,
                child: const Text(AppStrings.previous),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: onReview,
                child: Text(
                  marked
                      ? AppStrings.simulationMarkedForReview
                      : AppStrings.simulationReviewLater,
                ),
              ),
            ),
          ],
        ),
        if (hasAnswer)
          AppButton(
            label: isLast ? AppStrings.finish : AppStrings.next,
            onPressed: onNext,
          )
        else
          AppButton(
            label: isLast ? AppStrings.finish : AppStrings.skip,
            onPressed: onSkip,
          ),
      ],
    ),
  );
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}
