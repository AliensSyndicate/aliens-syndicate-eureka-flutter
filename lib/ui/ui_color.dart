import 'package:flutter/material.dart';

import '../enums/subject_type.dart';

abstract final class UiColor {
  // Identidade principal
  static const background = Color(0xFF2D2636);
  static const navigationBackground = Color(0xFF322A37);
  static const accent = Color(0xFFD38DFD);
  static const text = Color(0xFFF9F4FC);

  // Superfícies derivadas
  static const surface = Color(0xFF352C3A);
  static const surfaceElevated = Color(0xFF403447);

  // Marca e ações
  static const primary = accent;
  static const secondary = accent;

  // Texto
  static const textPrimary = text;
  static const textSecondary = Color(0xFFC8BBCD);
  static const textDisabled = Color(0xFF817585);

  // Estrutura
  static const outline = Color(0xFF594A60);
  static const divider = Color(0xFF493D4F);

  // Feedback
  static const success = Color(0xFF58CC02);
  static const error = Color(0xFFFF4B4B);
  static const warning = Color(0xFFFFC800);
  static const info = Color(0xFF1CB0F6);

  // Recomendação
  static const recommendationBase = Color(0xFFF7CA45);
  static const recommendationStripe = Color(0xFFF9DA49);
  static const recommendationBorder = Color(0xFFDFA93A);

  // Matérias
  static const mathematics = Color(0xFF1CB0F6);
  static const portuguese = Color(0xFFFF6B9D);
  static const english = Color(0xFF9B7BFF);
  static const spanish = Color(0xFFFFB84D);
  static const science = Color(0xFF58CC02);
  static const biology = Color(0xFF20C997);
  static const physics = Color(0xFF5C7CFA);
  static const chemistry = Color(0xFFB56BFF);
  static const history = Color(0xFFFF9600);
  static const geography = Color(0xFFCE82FF);
  static const philosophy = Color(0xFFE66B8C);
  static const sociology = Color(0xFF4DABF7);

  static Color forSubject(SubjectType value) => switch (value) {
    SubjectType.mathematics => mathematics,
    SubjectType.portuguese => portuguese,
    SubjectType.english => english,
    SubjectType.spanish => spanish,
    SubjectType.science => science,
    SubjectType.biology => biology,
    SubjectType.physics => physics,
    SubjectType.chemistry => chemistry,
    SubjectType.history => history,
    SubjectType.geography => geography,
    SubjectType.philosophy => philosophy,
    SubjectType.sociology => sociology,
  };
}
