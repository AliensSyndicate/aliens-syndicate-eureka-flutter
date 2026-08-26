import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/controller_auth.dart';
import '../../enums/login_context.dart';
import '../../models/auth/model_login_request.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import 'widget_login_content.dart';

class PageAuth extends StatelessWidget {
  const PageAuth({this.controller, super.key});

  final AuthController? controller;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
    child: PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/home.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              excludeFromSemantics: true,
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 200,
                        child: UiIcon.logo(size: UiSize.avatarLg),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: UiColor.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(UiRadius.card),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(UiSpacing.cardPadding),
                        child: LoginContent(
                          request: const LoginRequest(
                            context: LoginContext.profile,
                          ),
                          controller: controller,
                          onAuthenticated: () {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
