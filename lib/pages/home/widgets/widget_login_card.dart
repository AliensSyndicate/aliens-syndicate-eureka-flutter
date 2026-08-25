import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import 'widget_action_planet_button.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    required this.onTap,
    this.width = 80.0,
    this.height = 80.0,
    super.key,
  });

  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ActionPlanetButton(
        semanticLabel: AppStrings.signInWithYourAccount,
        label: AppStrings.signInWithYourAccount,
        labelColor: UiColor.loginBorder,
        imageAsset: 'assets/images/login.png',
        onTap: onTap,
      ),
    );
  }
}
