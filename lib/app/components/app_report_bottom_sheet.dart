import 'package:flutter/material.dart';

import '../../enums/report_context.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_question.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_option.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_snackbar.dart';

class AppReportBottomSheet extends StatefulWidget {
  const AppReportBottomSheet({
    this.lessonId,
    this.lessonTitle,
    this.question,
    this.subjectId,
    this.pageNumber,
    this.reportContext,
    this.options,
    super.key,
  });

  final String? lessonId;
  final String? lessonTitle;
  final Question? question;
  final String? subjectId;
  final int? pageNumber;
  final ReportContext? reportContext;
  final List<String>? options;

  static List<String> optionsForContext(ReportContext context) =>
      switch (context) {
        ReportContext.subject => const [
          AppStrings.reportOptionWritingError,
          AppStrings.reportOptionLogicError,
          AppStrings.reportOptionOtherError,
        ],
        ReportContext.lessonContent => const [
          AppStrings.reportOptionAudioIncorrect,
          AppStrings.reportOptionAudioMissing,
          AppStrings.reportOptionWritingError,
          AppStrings.reportOptionLogicError,
          AppStrings.reportOptionOtherError,
        ],
        ReportContext.lessonActivity => const [
          AppStrings.reportOptionWrongAnswer,
          AppStrings.reportOptionWritingError,
          AppStrings.reportOptionLogicError,
          AppStrings.reportOptionOtherError,
        ],
        ReportContext.general => const [
          AppStrings.reportOptionAudioIncorrect,
          AppStrings.reportOptionAudioMissing,
          AppStrings.reportOptionWritingError,
          AppStrings.reportOptionLogicError,
          AppStrings.reportOptionWrongAnswer,
          AppStrings.reportOptionOtherError,
        ],
      };

  static Future<void> show(
    BuildContext context, {
    String? lessonId,
    String? lessonTitle,
    Question? question,
    String? subjectId,
    int? pageNumber,
    ReportContext? reportContext,
    List<String>? options,
  }) => AppBottomSheet.show<void>(
    context,
    title: AppStrings.reportProblemTitle,
    content: AppReportBottomSheet(
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      question: question,
      subjectId: subjectId,
      pageNumber: pageNumber,
      reportContext: reportContext,
      options: options,
    ),
  );

  @override
  State<AppReportBottomSheet> createState() => _AppReportBottomSheetState();
}

class _AppReportBottomSheetState extends State<AppReportBottomSheet> {
  final _detailsController = TextEditingController();
  final Set<String> _selectedOptions = <String>{};
  bool _isSubmitting = false;

  List<String> get _options {
    if (widget.options != null && widget.options!.isNotEmpty) {
      return widget.options!;
    }
    if (widget.reportContext != null) {
      return AppReportBottomSheet.optionsForContext(widget.reportContext!);
    }
    if (widget.question != null) {
      return AppReportBottomSheet.optionsForContext(
        ReportContext.lessonActivity,
      );
    }
    return AppReportBottomSheet.optionsForContext(ReportContext.general);
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  Future<void> _submit() async {
    final details = _detailsController.text.trim();
    if (_selectedOptions.isEmpty && details.isEmpty) return;

    setState(() => _isSubmitting = true);

    final success = await ServiceRegistry.report.sendReport(
      reasons: _selectedOptions.toList(),
      details: details,
      lessonId: widget.lessonId,
      lessonTitle: widget.lessonTitle,
      questionId: widget.question?.id,
      questionPrompt: widget.question?.prompt,
      subjectId: widget.subjectId,
      pageNumber: widget.pageNumber,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    AppSnackBar.show(
      context,
      message: success
          ? AppStrings.reportSentSuccess
          : AppStrings.reportSentFailure,
      type: success ? AppSnackBarType.success : AppSnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _selectedOptions.isNotEmpty ||
        _detailsController.text.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.reportProblemDescription,
          style: UiText.p.copyWith(color: UiColor.textSecondary),
        ),
        const SizedBox(height: UiSpacing.md),
        ..._options.map((option) {
          final isSelected = _selectedOptions.contains(option);
          return _ReportOptionTile(
            option: option,
            isSelected: isSelected,
            onTap: () => _toggleOption(option),
          );
        }),
        const SizedBox(height: UiSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: UiColor.surface,
            borderRadius: BorderRadius.circular(UiRadius.input),
            border: Border.all(
              color: UiColor.outline,
              width: UiOption.borderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.md,
            vertical: UiSpacing.sm,
          ),
          child: TextField(
            controller: _detailsController,
            onChanged: (_) => setState(() {}),
            maxLines: 3,
            minLines: 3,
            cursorColor: UiColor.primary,
            style: UiText.p.copyWith(color: UiColor.textPrimary),
            decoration: InputDecoration(
              hintText: AppStrings.reportDetailsHint,
              hintStyle: UiText.p.copyWith(color: UiColor.textSecondary),
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
        const SizedBox(height: UiSpacing.lg),
        AppButton(
          label: AppStrings.send,
          isLoading: _isSubmitting,
          onPressed: canSubmit && !_isSubmitting ? _submit : null,
        ),
      ],
    );
  }
}

class _ReportOptionTile extends StatelessWidget {
  const _ReportOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? UiColor.accent : UiColor.outline;
    final textColor = isSelected ? UiColor.accent : UiColor.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.xs),
      child: Semantics(
        selected: isSelected,
        button: true,
        label: option,
        child: Material(
          color: UiColor.surface,
          borderRadius: BorderRadius.circular(UiOption.radius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiOption.radius),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48.0),
              padding: const EdgeInsets.symmetric(
                horizontal: UiOption.paddingHorizontal,
                vertical: UiSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UiOption.radius),
                border: Border.all(
                  color: borderColor,
                  width: UiOption.borderWidth,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: UiText.p.copyWith(
                        color: textColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: UiSpacing.sm),
                  _ReportCheckbox(isSelected: isSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCheckbox extends StatelessWidget {
  const _ReportCheckbox({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? UiColor.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? UiColor.accent : UiColor.outline,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? UiIcon.check(size: 14, color: UiColor.background)
          : null,
    );
  }
}
