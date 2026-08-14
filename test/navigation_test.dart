import 'package:eureka/l10n/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
