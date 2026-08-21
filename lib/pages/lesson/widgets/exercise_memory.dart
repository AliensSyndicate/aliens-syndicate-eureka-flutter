import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_matching_pair.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Exercício de jogo da memória.
///
/// Cada par vira duas cartas embaralhadas. Ao revelar duas cartas do mesmo par
/// elas ficam abertas; caso contrário voltam a esconder. Quando todos os pares
/// são encontrados, dispara [onCompleted].
class ExerciseMemory extends StatefulWidget {
  const ExerciseMemory({
    required this.pairs,
    required this.primaryColor,
    required this.onCompleted,
    this.enabled = true,
    super.key,
  });

  final List<MatchingPair> pairs;
  final Color primaryColor;
  final ValueChanged<bool> onCompleted;
  final bool enabled;

  @override
  State<ExerciseMemory> createState() => _ExerciseMemoryState();
}

class _ExerciseMemoryState extends State<ExerciseMemory> {
  static const _columns = 4;
  static const _hideDelay = Duration(milliseconds: 700);

  late final List<_MemoryCard> _cards;
  final List<int> _revealed = [];
  final Set<int> _matched = {};

  bool _busy = false;
  bool _missed = false;

  @override
  void initState() {
    super.initState();
    _cards = [
      for (final entry in widget.pairs.indexed) ...[
        _MemoryCard(pairIndex: entry.$1, label: entry.$2.left),
        _MemoryCard(pairIndex: entry.$1, label: entry.$2.right),
      ],
    ]..shuffle(math.Random());
  }

  bool _isOpen(int index) =>
      _matched.contains(index) || _revealed.contains(index);

  Future<void> _flip(int index) async {
    if (!widget.enabled || _busy || _isOpen(index)) return;

    setState(() => _revealed.add(index));
    if (_revealed.length < 2) return;

    _busy = true;
    final first = _revealed[0];
    final second = _revealed[1];
    final matched = _cards[first].pairIndex == _cards[second].pairIndex;

    if (matched) {
      setState(() {
        _matched.addAll([first, second]);
        _revealed.clear();
      });
    } else {
      _missed = true;
      await Future<void>.delayed(_hideDelay);
      if (!mounted) return;
      setState(_revealed.clear);
    }
    _busy = false;

    if (_matched.length == _cards.length) {
      widget.onCompleted(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foundPairs = _matched.length ~/ 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _columns,
          mainAxisSpacing: UiSpacing.xs,
          crossAxisSpacing: UiSpacing.xs,
          childAspectRatio: .82,
          children: _cards.indexed.map((entry) {
            final index = entry.$1;
            return _FlipCard(
              key: ValueKey('memory-card-$index'),
              label: entry.$2.label,
              revealed: _isOpen(index),
              matched: _matched.contains(index),
              accentColor: widget.primaryColor,
              onTap: () => _flip(index),
            );
          }).toList(),
        ),
        const SizedBox(height: UiSpacing.md),
        _Stat(
          icon: UiIcon.star(
            color: _missed ? UiColor.warning : UiColor.success,
            size: UiSize.iconSm,
          ),
          value: AppStrings.memoryPairs(foundPairs, widget.pairs.length),
          color: _missed ? UiColor.warning : UiColor.success,
        ),
      ],
    );
  }
}

class _MemoryCard {
  const _MemoryCard({required this.pairIndex, required this.label});

  final int pairIndex;
  final String label;
}

/// Carta com giro no eixo Y ao revelar.
class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.label,
    required this.revealed,
    required this.matched,
    required this.accentColor,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool revealed;
  final bool matched;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: revealed ? 1 : 0),
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeInOut,
    builder: (context, value, child) {
      final showFront = value >= .5;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .0015)
          ..rotateY(value * math.pi),
        child: showFront
            // A face aberta é contra-rotacionada para o texto não ficar espelhado.
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: _CardFace(
                  accent: matched ? UiColor.success : accentColor,
                  filled: true,
                  onTap: null,
                  child: Padding(
                    padding: const EdgeInsets.all(UiSpacing.xxs),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: matched ? UiColor.success : UiColor.textPrimary,
                      ),
                    ),
                  ),
                ),
              )
            : _CardFace(
                accent: UiColor.outline,
                filled: false,
                onTap: onTap,
                child: UiIcon.sparkles(
                  color: accentColor.withValues(alpha: .8),
                  size: UiSize.iconMd,
                ),
              ),
      );
    },
  );
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.accent,
    required this.filled,
    required this.onTap,
    required this.child,
  });

  final Color accent;
  final bool filled;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: filled ? accent.withValues(alpha: .16) : UiColor.surfaceElevated,
    borderRadius: BorderRadius.circular(UiOption.radius),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UiOption.radius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UiOption.radius),
          border: Border.all(color: accent, width: UiOption.borderWidth),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.color});

  final Widget icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      icon,
      const SizedBox(width: UiSpacing.xxs),
      Text(value, style: UiText.label.copyWith(color: color)),
    ],
  );
}
