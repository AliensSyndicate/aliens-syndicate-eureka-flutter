import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/auth/model_login_request.dart';
import '../../ui/ui_spacing.dart';
import 'widget_login_content.dart';

class PageAuth extends StatelessWidget {
  const PageAuth({required this.request, super.key});

  final LoginRequest request;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.pageHorizontal,
            vertical: UiSpacing.pageVertical,
          ),
          child: LoginContent(
            request: request,
            showLogo: true,
            onAuthenticated: () => _finish(context),
            onContinueWithoutAccount: () => _finish(context),
          ),
        ),
      ),
    ),
  );

  void _finish(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(request.returnLocation ?? '/home');
    }
  }
}
