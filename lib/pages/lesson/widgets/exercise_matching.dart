import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/model_matching_pair.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_question_prompt.dart';

enum _MatchingState { normal, selected, correct, incorrect }

const _pairColors = [
  UiColor.info,
  UiColor.warning,
  UiColor.portuguese,
  UiColor.biology,
  UiColor.chemistry,
];

class ExerciseMatching extends StatefulWidget {
  const ExerciseMatching({
    this.question,
    required this.pairs,
    required this.primaryColor,
    required this.onChanged,
    this.initialAnswer,
    this.answeredCorrect,
    this.enabled = true,
    super.key,
  });

  final Question? question;
  final List<MatchingPair> pairs;
  final Color primaryColor;
  final ValueChanged<String> onChanged;
  final String? initialAnswer;
  final bool? answeredCorrect;
  final bool enabled;

  @override
  State<ExerciseMatching> createState() => _ExerciseMatchingState();
}

class _ExerciseMatchingState extends State<ExerciseMatching> {
  late final List<String> _leftItems;
  late final List<String> _rightItems;
  final Map<String, String> _matches = {};
  String? _selectedLeft;
  String? _selectedRight;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _leftItems = widget.pairs.map((pair) => pair.left).toList()
      ..shuffle(random);
    _rightItems = widget.pairs.map((pair) => pair.right).toList()
      ..shuffle(random);
    _restore(widget.initialAnswer);
  }

  void _restore(String? answer) {
    if (answer == null || answer.isEmpty) return;
    try {
      final decoded = jsonDecode(answer);
      if (decoded is! Map) return;
      for (final entry in decoded.entries) {
        final left = entry.key.toString();
        final right = entry.value.toString();
        if (_leftItems.contains(left) && _rightItems.contains(right)) {
          _matches[left] = right;
        }
      }
    } on FormatException {
      return;
    }
  }

  void _tapLeft(String item) {
    if (!widget.enabled) return;
    if (_matches.containsKey(item)) {
      setState(() => _matches.remove(item));
      _notifyChange();
      return;
    }
    setState(() => _selectedLeft = _selectedLeft == item ? null : item);
    _commitSelection();
  }

  void _tapRight(String item) {
    if (!widget.enabled) return;
    final matchedLeft = _leftForRight(item);
    if (matchedLeft != null) {
      setState(() => _matches.remove(matchedLeft));
      _notifyChange();
      return;
    }
    setState(() => _selectedRight = _selectedRight == item ? null : item);
    _commitSelection();
  }

  void _commitSelection() {
    final left = _selectedLeft;
    final right = _selectedRight;
    if (left == null || right == null) return;
    setState(() {
      _matches[left] = right;
      _selectedLeft = null;
      _selectedRight = null;
    });
    _notifyChange();
  }

  void _notifyChange() {
    widget.onChanged(
      _matches.length == widget.pairs.length ? jsonEncode(_matches) : '',
    );
  }

  String? _leftForRight(String right) {
    for (final entry in _matches.entries) {
      if (entry.value == right) return entry.key;
    }
    return null;
  }

  bool _pairIsCorrect(String left, String right) =>
      widget.pairs.any((pair) => pair.left == left && pair.right == right);

  _MatchingState _leftState(String item) {
    final right = _matches[item];
    if (right != null) return _matchedState(item, right);
    return _selectedLeft == item
        ? _MatchingState.selected
        : _MatchingState.normal;
  }

  _MatchingState _rightState(String item) {
    final left = _leftForRight(item);
    if (left != null) return _matchedState(left, item);
    return _selectedRight == item
        ? _MatchingState.selected
        : _MatchingState.normal;
  }

  _MatchingState _matchedState(String left, String right) {
    if (widget.answeredCorrect == null) return _MatchingState.selected;
    return _pairIsCorrect(left, right)
        ? _MatchingState.correct
        : _MatchingState.incorrect;
  }

  int? _leftPairIndex(String item) =>
      _matches.containsKey(item) ? _leftItems.indexOf(item) : null;

  int? _rightPairIndex(String item) {
    final left = _leftForRight(item);
    return left == null ? null : _leftItems.indexOf(left);
  }

  Color _leftColor(String item) => _pairColor(_leftPairIndex(item));

  Color _rightColor(String item) => _pairColor(_rightPairIndex(item));

  Color _pairColor(int? index) => index == null
      ? widget.primaryColor
      : _pairColors[index % _pairColors.length];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.question != null)
        ExerciseQuestionPrompt(
          question: widget.question!,
          primaryColor: widget.primaryColor,
        ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _MatchingColumn(
              items: _leftItems,
              stateOf: _leftState,
              colorOf: _leftColor,
              pairIndexOf: _leftPairIndex,
              onTap: _tapLeft,
              enabled: widget.enabled,
            ),
          ),
          const SizedBox(width: UiSpacing.sm),
          Expanded(
            child: _MatchingColumn(
              items: _rightItems,
              stateOf: _rightState,
              colorOf: _rightColor,
              pairIndexOf: _rightPairIndex,
              onTap: _tapRight,
              enabled: widget.enabled,
            ),
          ),
        ],
      ),
    ],
  );
}

class _MatchingColumn extends StatelessWidget {
  const _MatchingColumn({
    required this.items,
    required this.stateOf,
    required this.colorOf,
    required this.pairIndexOf,
    required this.onTap,
    required this.enabled,
  });

  final List<String> items;
  final _MatchingState Function(String) stateOf;
  final Color Function(String) colorOf;
  final int? Function(String) pairIndexOf;
  final ValueChanged<String> onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    children: items
        .map(
          (item) => _MatchingChip(
            label: item,
            state: stateOf(item),
            selectionColor: colorOf(item),
            pairIndex: pairIndexOf(item),
            onTap: enabled ? () => onTap(item) : null,
          ),
        )
        .toList(),
  );
}

class _MatchingChip extends StatelessWidget {
  const _MatchingChip({
    required this.label,
    required this.state,
    required this.selectionColor,
    required this.pairIndex,
    required this.onTap,
  });

  final String label;
  final _MatchingState state;
  final Color selectionColor;
  final int? pairIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _MatchingState.normal => UiColor.outline,
      _MatchingState.selected => selectionColor,
      _MatchingState.correct => UiColor.success,
      _MatchingState.incorrect => UiColor.error,
    };
    final showResult =
        state == _MatchingState.correct || state == _MatchingState.incorrect;

    return Semantics(
      button: true,
      selected: state != _MatchingState.normal,
      label: pairIndex == null ? label : '$label, par ${pairIndex! + 1}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: UiSpacing.xs),
        child: Material(
          color: UiColor.surface,
          borderRadius: BorderRadius.circular(UiOption.radius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiOption.radius),
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UiOption.radius),
                border: Border.all(color: color, width: UiOption.borderWidth),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: state == _MatchingState.normal
                            ? UiColor.textPrimary
                            : color,
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
