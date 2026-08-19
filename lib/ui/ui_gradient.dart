import 'package:flutter/material.dart';

import '../enums/subject_type.dart';
import 'ui_color.dart';

abstract final class UiGradient {
  static const recommendation = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      UiColor.recommendationBase,
      UiColor.recommendationBase,
      UiColor.recommendationStripe,
      UiColor.recommendationStripe,
      UiColor.recommendationBase,
      UiColor.recommendationBase,
    ],
    stops: [0, .28, .28, .68, .68, 1],
  );

  static const continueLearning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      UiColor.continueBase,
      UiColor.continueBase,
      UiColor.continueStripe,
      UiColor.continueStripe,
      UiColor.continueBase,
      UiColor.continueBase,
    ],
    stops: [0, .28, .28, .68, .68, 1],
  );

  static const login = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      UiColor.loginBase,
      UiColor.loginBase,
      UiColor.loginStripe,
      UiColor.loginStripe,
      UiColor.loginBase,
      UiColor.loginBase,
    ],
    stops: [0, .28, .28, .68, .68, 1],
  );

  static LinearGradient forSubject(SubjectType subject) {
    final base = UiColor.forSubject(subject);
    final stripe = UiColor.subjectStripe(subject);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [base, base, stripe, stripe, base, base],
      stops: const [0, .28, .28, .68, .68, 1],
    );
  }
}
