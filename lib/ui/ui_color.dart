import 'package:flutter/material.dart';

import '../enums/subject_type.dart';

abstract final class UiColor {
  static const background = Color(0xFFF7F8FC),
      surface = Colors.white,
      primary = Color(0xFF6C5CE7),
      secondary = Color(0xFF00B894),
      textPrimary = Color(0xFF24283B),
      textSecondary = Color(0xFF6B7280),
      outline = Color(0xFFE6E8F0),
      mathematics = Color(0xFF5B8DEF),
      portuguese = Color(0xFFEF6F91),
      science = Color(0xFF35B779),
      history = Color(0xFFF2A65A),
      geography = Color(0xFF8E6BBE);

  static Color forSubject(SubjectType value) => switch (value) {
    SubjectType.mathematics => mathematics,
    SubjectType.portuguese => portuguese,
    SubjectType.science => science,
    SubjectType.history => history,
    SubjectType.geography => geography,
  };
}
