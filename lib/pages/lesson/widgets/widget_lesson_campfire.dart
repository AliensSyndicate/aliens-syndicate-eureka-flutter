import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_motion.dart';

class WidgetLessonCampfire extends StatefulWidget {
  const WidgetLessonCampfire({super.key});

  @override
  State<WidgetLessonCampfire> createState() => _WidgetLessonCampfireState();
}

class _WidgetLessonCampfireState extends State<WidgetLessonCampfire>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool? animationsDisabled;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: UiMotion.campfireFlickerDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant WidgetLessonCampfire oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    final shouldDisable =
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    if (animationsDisabled == shouldDisable) return;
    animationsDisabled = shouldDisable;
    if (shouldDisable) {
      controller
        ..stop()
        ..value = .5;
    } else {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: AppStrings.lessonCampfireIllustration,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) => CustomPaint(
            key: const Key('lesson-loading-fire'),
            painter: LessonCampfirePainter(controller.value),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class LessonCampfirePainter extends CustomPainter {
  const LessonCampfirePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height * .72);
    final center = Offset(size.width / 2, size.height * .68);
    _paintLandscape(canvas, size);
    _paintLogs(canvas, center, unit);
    _paintFlame(canvas, center.translate(0, -unit * .06), unit);
  }

  void _paintLandscape(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(size.width * .30, size.height)
      ..cubicTo(
        size.width * .12,
        size.height * .78,
        size.width * .17,
        size.height * .42,
        size.width * .46,
        size.height * .45,
      )
      ..cubicTo(
        size.width * .68,
        size.height * .47,
        size.width * .65,
        size.height * .20,
        size.width,
        size.height * .16,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = UiColor.surface);

    final front = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .91)
      ..cubicTo(
        size.width * .25,
        size.height * .77,
        size.width * .54,
        size.height * .88,
        size.width,
        size.height * .70,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = UiColor.surfaceElevated);
  }

  void _paintLogs(Canvas canvas, Offset center, double unit) {
    void drawLog(double angle) {
      canvas.save();
      canvas.translate(center.dx, center.dy + unit * .27);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: unit * .88,
            height: unit * .17,
          ),
          Radius.circular(unit * .085),
        ),
        Paint()..color = UiColor.outline,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-unit * .30, -unit * .085, unit * .18, unit * .17),
          Radius.circular(unit * .025),
        ),
        Paint()..color = UiColor.surfaceElevated,
      );
      canvas.drawCircle(
        Offset(unit * .36, 0),
        unit * .085,
        Paint()..color = UiColor.accent,
      );
      canvas.drawCircle(
        Offset(unit * .36, 0),
        unit * .045,
        Paint()
          ..color = UiColor.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = unit * .016,
      );
      canvas.restore();
    }

    drawLog(-.22);
    drawLog(.20);
  }

  void _paintFlame(Canvas canvas, Offset center, double unit) {
    final phase = progress * math.pi * 2;
    final sway = math.sin(phase) * unit * .018;
    final stretch = 1 + math.sin(phase + math.pi / 2) * .035;
    canvas.save();
    canvas.translate(center.dx + sway, center.dy);
    canvas.scale(1 / stretch, stretch);
    canvas.drawCircle(
      Offset(0, -unit * .18),
      unit * (.34 + math.sin(phase) * .012),
      Paint()..color = UiColor.accent.withValues(alpha: .10),
    );

    final outer = Path()
      ..moveTo(0, unit * .24)
      ..cubicTo(
        -unit * .30,
        unit * .23,
        -unit * .35,
        0,
        -unit * .22,
        -unit * .24,
      )
      ..cubicTo(
        -unit * .13,
        -unit * .42,
        -unit * .08,
        -unit * .29,
        -unit * .09,
        -unit * .14,
      )
      ..cubicTo(
        -unit * .09,
        -unit * .06,
        -unit * .02,
        -unit * .08,
        -unit * .03,
        -unit * .18,
      )
      ..cubicTo(
        -unit * .06,
        -unit * .39,
        unit * .12,
        -unit * .45,
        unit * .12,
        -unit * .62,
      )
      ..cubicTo(unit * .34, -unit * .43, unit * .37, -unit * .17, unit * .34, 0)
      ..cubicTo(unit * .31, unit * .18, unit * .18, unit * .24, 0, unit * .24)
      ..close();
    canvas.drawPath(outer, Paint()..color = UiColor.accent);

    final inner = Path()
      ..moveTo(0, unit * .19)
      ..cubicTo(
        -unit * .20,
        unit * .18,
        -unit * .24,
        0,
        -unit * .16,
        -unit * .15,
      )
      ..cubicTo(
        -unit * .07,
        -unit * .07,
        0,
        -unit * .02,
        unit * .08,
        -unit * .12,
      )
      ..cubicTo(
        unit * .14,
        -unit * .20,
        unit * .10,
        -unit * .32,
        unit * .14,
        -unit * .36,
      )
      ..cubicTo(
        unit * .30,
        -unit * .19,
        unit * .29,
        unit * .03,
        unit * .23,
        unit * .12,
      )
      ..cubicTo(unit * .17, unit * .19, unit * .10, unit * .20, 0, unit * .19)
      ..close();
    canvas.drawPath(inner, Paint()..color = UiColor.xp);

    final facePaint = Paint()
      ..color = UiColor.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * .018
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawPath(
        Path()
          ..moveTo(-unit * .13, -unit * .01)
          ..quadraticBezierTo(-unit * .08, unit * .06, -unit * .03, 0),
        facePaint,
      )
      ..drawPath(
        Path()
          ..moveTo(unit * .04, 0)
          ..quadraticBezierTo(unit * .09, unit * .06, unit * .14, -unit * .01),
        facePaint,
      )
      ..drawPath(
        Path()
          ..moveTo(-unit * .05, unit * .09)
          ..quadraticBezierTo(0, unit * .15, unit * .06, unit * .09),
        facePaint,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(LessonCampfirePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
