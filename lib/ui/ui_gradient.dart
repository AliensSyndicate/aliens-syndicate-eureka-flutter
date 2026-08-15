import 'package:flutter/material.dart';

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
}
