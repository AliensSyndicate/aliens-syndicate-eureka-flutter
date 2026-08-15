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

  // Matérias
  static const mathematics = Color(0xFF1CB0F6);
  static const portuguese = Color(0xFFFF6B9D);
  static const science = Color(0xFF58CC02);
  static const history = Color(0xFFFF9600);
  static const geography = Color(0xFFCE82FF);

  static Color forSubject(SubjectType value) => switch (value) {
    SubjectType.mathematics => mathematics,
    SubjectType.portuguese => portuguese,
    SubjectType.science => science,
    SubjectType.history => history,
    SubjectType.geography => geography,
  };
}
