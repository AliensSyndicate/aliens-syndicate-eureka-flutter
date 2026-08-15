import 'ui_text.dart';

abstract final class UiTypography {
  // Compatibilidade: novos componentes devem usar UiText diretamente.
  static const title = UiText.h3;
  static const heading = UiText.h5;
  static const body = UiText.p;
  static const caption = UiText.label;
}
