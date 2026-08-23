import 'package:eureka/ui/ui_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapeia as cores dos níveis de dificuldade', () {
    expect(UiColor.forDifficulty(1), UiColor.success);
    expect(UiColor.forDifficulty(2), UiColor.warning);
    expect(UiColor.forDifficulty(3), UiColor.error);
  });
}
