import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/model_matching_pair.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_question_prompt.dart';

enum _Feedback { none, selected, correct, incorrect }

/// Exercício de ligação (matching).
///
/// Exibe duas colunas de opções embaralhadas. O usuário seleciona um item de cada
/// coluna para formar um par.
/// - Não é possível tentar novamente: se acertar, o par fica verde; se errar, o par fica vermelho.
/// - As opções permanecem visíveis na tela.
/// - Ao responder todos os pares, dispara [onCompleted] informando se todos foram corretos.
class ExerciseMatching extends StatefulWidget {
  const ExerciseMatching({
    this.question,
    required this.pairs,
    required this.primaryColor,
    required this.onCompleted,
    this.enabled = true,
    super.key,
  });

  final Question? question;
  final List<MatchingPair> pairs;
  final Color primaryColor;
  final ValueChanged<bool> onCompleted;
  final bool enabled;

  @override
  State<ExerciseMatching> createState() => _ExerciseMatchingState();
}

class _ExerciseMatchingState extends State<ExerciseMatching>
    with SingleTickerProviderStateMixin {
  late final List<String> _leftItems;
  late final List<String> _rightItems;

  String? _selectedLeft;
  String? _selectedRight;

  final Set<String> _correctLeft = {};
  final Set<String> _correctRight = {};
  final Set<String> _incorrectLeft = {};
  final Set<String> _incorrectRight = {};

  bool _busy = false;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _leftItems = widget.pairs.map((p) => p.left).toList()..shuffle(rng);
    _rightItems = widget.pairs.map((p) => p.right).toList()..shuffle(rng);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  _Feedback _leftState(String item) {
    if (_correctLeft.contains(item)) return _Feedback.correct;
    if (_incorrectLeft.contains(item)) return _Feedback.incorrect;
    if (_selectedLeft == item) return _Feedback.selected;
    return _Feedback.none;
  }

  _Feedback _rightState(String item) {
    if (_correctRight.contains(item)) return _Feedback.correct;
    if (_incorrectRight.contains(item)) return _Feedback.incorrect;
    if (_selectedRight == item) return _Feedback.selected;
    return _Feedback.none;
  }

  bool _isLeftLocked(String item) =>
      _correctLeft.contains(item) || _incorrectLeft.contains(item);

  bool _isRightLocked(String item) =>
      _correctRight.contains(item) || _incorrectRight.contains(item);

  void _tapLeft(String item) {
    if (_busy || _isLeftLocked(item)) return;
    setState(() {
      _selectedLeft = _selectedLeft == item ? null : item;
    });
    _tryCheck();
  }

  void _tapRight(String item) {
    if (_busy || _isRightLocked(item)) return;
    setState(() {
      _selectedRight = _selectedRight == item ? null : item;
    });
    _tryCheck();
  }

  void _tryCheck() {
    if (_selectedLeft == null || _selectedRight == null) return;
    _checkPair(_selectedLeft!, _selectedRight!);
  }

  Future<void> _checkPair(String left, String right) async {
    _busy = true;
    final correct = widget.pairs.any((p) => p.left == left && p.right == right);

    setState(() {
      if (correct) {
        _correctLeft.add(left);
        _correctRight.add(right);
      } else {
        _incorrectLeft.add(left);
        _incorrectRight.add(right);
      }
      _selectedLeft = null;
      _selectedRight = null;
    });

    if (!correct) {
      await _shakeCtrl.forward(from: 0);
    }

    _busy = false;

    final totalAnswered = _correctLeft.length + _incorrectLeft.length;
    if (totalAnswered == widget.pairs.length) {
      final allCorrect = _incorrectLeft.isEmpty;
      widget.onCompleted(allCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.question != null)
          ExerciseQuestionPrompt(
            question: widget.question!,
            primaryColor: widget.primaryColor,
          ),
        AnimatedBuilder(
          animation: _shakeAnim,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnim.value, 0),
            child: child,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Column(
                  items: _leftItems,
                  stateOf: _leftState,
                  onTap: widget.enabled ? _tapLeft : (_) {},
                  accentColor: widget.primaryColor,
                ),
              ),
              const SizedBox(width: UiSpacing.sm),
              Expanded(
                child: _Column(
                  items: _rightItems,
                  stateOf: _rightState,
                  onTap: widget.enabled ? _tapRight : (_) {},
                  accentColor: widget.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.items,
    required this.stateOf,
    required this.onTap,
    required this.accentColor,
  });

  final List<String> items;
  final _Feedback Function(String) stateOf;
  final void Function(String) onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final fb = stateOf(item);
        return _Chip(
          label: item,
          feedback: fb,
          accentColor: accentColor,
          onTap: () => onTap(item),
        );
      }).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.feedback,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final _Feedback feedback;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = switch (feedback) {
      _Feedback.selected => accentColor,
      _Feedback.correct => UiColor.success,
      _Feedback.incorrect => UiColor.error,
      _ => UiColor.outline,
    };

    final bool isLocked =
        feedback == _Feedback.correct || feedback == _Feedback.incorrect;
    final bool interactive = !isLocked;

    final showStatus =
        feedback == _Feedback.correct || feedback == _Feedback.incorrect;

    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.xs),
      child: Material(
        color: UiColor.surface,
        borderRadius: BorderRadius.circular(UiOption.radius),
        child: InkWell(
          onTap: interactive ? onTap : null,
          borderRadius: BorderRadius.circular(UiOption.radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 52),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UiOption.radius),
              border: Border.all(color: border, width: UiOption.borderWidth),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showStatus) ...[
                  feedback == _Feedback.correct
                      ? UiIcon.correct(color: border, size: 16)
                      : UiIcon.incorrect(color: border, size: 16),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: feedback == _Feedback.none
                          ? UiColor.textPrimary
                          : border,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
