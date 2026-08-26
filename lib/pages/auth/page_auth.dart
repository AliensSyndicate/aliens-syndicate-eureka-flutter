import 'package:flutter/material.dart';

import '../../controllers/controller_auth.dart';
import '../../enums/login_context.dart';
import '../../models/auth/model_login_request.dart';
import '../../ui/ui_spacing.dart';
import 'widget_login_content.dart';

class PageAuth extends StatelessWidget {
  const PageAuth({this.controller, super.key});

  final AuthController? controller;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/auth.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            excludeFromSemantics: true,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiSpacing.pageHorizontal,
                  vertical: UiSpacing.pageVertical,
                ),
                child: LoginContent(
                  request: const LoginRequest(context: LoginContext.profile),
                  controller: controller,
                  onAuthenticated: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
