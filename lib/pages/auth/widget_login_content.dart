import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/config_product.dart';
import '../../controllers/controller_auth.dart';
import '../../l10n/app_strings.dart';
import '../../models/auth/model_auth_result.dart';
import '../../models/auth/model_login_request.dart';
import '../../enums/login_context.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({
    required this.request,
    required this.onAuthenticated,
    required this.onContinueWithoutAccount,
    this.showLogo = false,
    this.showHeading = true,
    this.controller,
    super.key,
  });

  final LoginRequest request;
  final VoidCallback onAuthenticated;
  final VoidCallback onContinueWithoutAccount;
  final bool showLogo;
  final bool showHeading;
  final AuthController? controller;

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  late final AuthController controller;
  late final Future<bool> appleAvailable;
  late final bool ownsController;

  @override
  void initState() {
    super.initState();
    ownsController = widget.controller == null;
    controller = widget.controller ?? AuthController(ServiceRegistry.auth);
    controller.addListener(_refresh);
    appleAvailable = controller.isAppleSignInAvailable();
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    if (ownsController) controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _signIn(AuthProvider provider) async {
    final authenticated = await controller.signIn(provider);
    if (authenticated && mounted) widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.showLogo) ...[
        Center(child: UiIcon.logo(size: UiSize.avatarMd)),
        const SizedBox(height: UiSpacing.lg),
      ],
      if (widget.showHeading) ...[
        Semantics(
          header: true,
          child: Text(
            AppStrings.loginTitle(widget.request.context),
            style: UiText.h3,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: UiSpacing.sm),
      ],
      Text(
        AppStrings.loginDescription(widget.request.context),
        style: UiText.p,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: UiSpacing.xs),
      Text(
        AppStrings.authCreateOrSignIn,
        style: UiText.label,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: UiSpacing.xl),
      _ProviderButton(
        key: const Key('login_google'),
        label: AppStrings.continueWithGoogle,
        mark: const Text('G', style: TextStyle(fontWeight: FontWeight.w800)),
        isLoading:
            controller.isBusy &&
            controller.loadingProvider == AuthProvider.google,
        onPressed: controller.isBusy
            ? null
            : () => _signIn(AuthProvider.google),
      ),
      const SizedBox(height: UiSpacing.sm),
      FutureBuilder<bool>(
        future: appleAvailable,
        builder: (context, snapshot) => snapshot.data == true
            ? _ProviderButton(
                key: const Key('login_apple'),
                label: AppStrings.continueWithApple,
                mark: const Icon(Icons.apple, size: UiSize.iconSm),
                isLoading:
                    controller.isBusy &&
                    controller.loadingProvider == AuthProvider.apple,
                onPressed: controller.isBusy
                    ? null
                    : () => _signIn(AuthProvider.apple),
              )
            : const SizedBox.shrink(),
      ),
      if (controller.status == AuthStatus.error) ...[
        const SizedBox(height: UiSpacing.sm),
        Semantics(
          liveRegion: true,
          child: Text(
            controller.message ?? AppStrings.authUnavailable,
            style: UiText.label.copyWith(color: UiColor.error),
            textAlign: TextAlign.center,
          ),
        ),
      ],
      if (widget.request.context == LoginContext.saveProgress) ...[
        const SizedBox(height: UiSpacing.sm),
        TextButton(
          onPressed: controller.isBusy ? null : widget.onContinueWithoutAccount,
          child: const Text(AppStrings.continueWithoutAccount),
        ),
      ],
      const SizedBox(height: UiSpacing.lg),
      const _LegalText(),
    ],
  );
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.mark,
    required this.onPressed,
    required this.isLoading,
    super.key,
  });

  final String label;
  final Widget mark;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    child: SizedBox(
      height: UiSize.touchTarget,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: UiColor.textPrimary,
          side: const BorderSide(color: UiColor.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiSize.touchTarget / 2),
          ),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: UiSize.iconSm,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Align(alignment: Alignment.centerLeft, child: mark),
                  Text(label, style: UiText.p),
                ],
              ),
      ),
    ),
  );
}

class _LegalText extends StatelessWidget {
  const _LegalText();

  @override
  Widget build(BuildContext context) {
    final terms = Uri.tryParse(ProductConfig.termsUrl);
    final privacy = Uri.tryParse(ProductConfig.privacyUrl);
    final linkStyle = UiText.label.copyWith(color: UiColor.accent);
    return Text.rich(
      TextSpan(
        style: UiText.label,
        children: [
          const TextSpan(text: AppStrings.authTermsPrefix),
          TextSpan(
            text: AppStrings.termsOfUse,
            style: linkStyle,
            recognizer: terms == null
                ? null
                : (TapGestureRecognizer()..onTap = () => launchUrl(terms)),
          ),
          const TextSpan(text: AppStrings.andLabel),
          TextSpan(
            text: AppStrings.privacyPolicy,
            style: linkStyle,
            recognizer: privacy == null
                ? null
                : (TapGestureRecognizer()..onTap = () => launchUrl(privacy)),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
