import 'package:eureka/app/navigation/navigation_router.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/ui/ui_motion.dart';
import 'package:eureka/ui/ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  test('mantém a ordem obrigatória da navegação principal', () {
    expect(
      [
        AppStrings.home,
        AppStrings.social,
        AppStrings.explore,
        AppStrings.simulation,
        AppStrings.profile,
      ],
      ['Home', 'Social', 'Explorar', 'Simulado', 'Profile'],
    );
  });

  test('expõe todas as rotas nomeadas da aplicação', () {
    expect(appRouter.namedLocation(AppRoute.home), '/home');
    expect(appRouter.namedLocation(AppRoute.social), '/social');
    expect(appRouter.namedLocation(AppRoute.explore), '/explore');
    expect(appRouter.namedLocation(AppRoute.simulation), '/simulation');
    expect(appRouter.namedLocation(AppRoute.profile), '/profile');
    expect(appRouter.namedLocation(AppRoute.lessonLoading), '/lesson/loading');
    expect(appRouter.namedLocation(AppRoute.lesson), '/lesson');
    expect(appRouter.namedLocation(AppRoute.activityResult), '/lesson/result');
  });

  test('usa a transição de tela centralizada no design system', () {
    expect(
      UiMotion.screenTransitionDuration,
      const Duration(milliseconds: 300),
    );
    expect(UiMotion.screenTransitionCurve, Curves.easeOutCubic);
    expect(UiMotion.screenTransitionOffset, const Offset(0.08, 0));
  });

  testWidgets('usa HugeIcons na seta automática de voltar do AppBar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(appBar: AppBar(leading: const BackButton())),
      ),
    );

    final icon = tester.widget<HugeIcon>(find.byType(HugeIcon));
    expect(icon.icon, same(HugeIcons.strokeRoundedArrowLeft02));
  });
}
