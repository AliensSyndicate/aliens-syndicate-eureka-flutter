import 'package:eureka/controllers/controller_auth.dart';
import 'package:eureka/enums/login_context.dart';
import 'package:eureka/interfaces/repository_auth.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/auth/model_auth_result.dart';
import 'package:eureka/models/auth/model_login_request.dart';
import 'package:eureka/pages/auth/widget_login_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('contexto de progresso permite continuar sem conta', (
    tester,
  ) async {
    var continued = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginContent(
            request: const LoginRequest(context: LoginContext.saveProgress),
            controller: AuthController(_FakeAuthRepository(apple: false)),
            onAuthenticated: () {},
            onContinueWithoutAccount: () => continued = true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.continueWithGoogle), findsOneWidget);
    expect(find.text(AppStrings.authCreateOrSignIn), findsOneWidget);
    expect(find.text(AppStrings.continueWithApple), findsNothing);
    expect(find.text(AppStrings.continueWithoutAccount), findsOneWidget);
    await tester.tap(find.text(AppStrings.continueWithoutAccount));
    expect(continued, isTrue);
  });

  testWidgets('contexto Social não oferece saída de progresso', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginContent(
            request: const LoginRequest(context: LoginContext.social),
            controller: AuthController(_FakeAuthRepository(apple: true)),
            onAuthenticated: () {},
            onContinueWithoutAccount: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.continueWithApple), findsOneWidget);
    expect(find.text(AppStrings.continueWithoutAccount), findsNothing);
    expect(
      find.text(AppStrings.loginTitle(LoginContext.social)),
      findsOneWidget,
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.apple});

  final bool apple;

  @override
  Stream<bool> get authenticationChanges => const Stream.empty();

  @override
  bool get isAuthenticated => false;

  @override
  String? get providerLabel => null;

  @override
  Future<bool> isAppleSignInAvailable() async => apple;

  @override
  Future<void> reconcileSession() async {}

  @override
  Future<AuthResult> signIn(AuthProvider provider) async =>
      const AuthResult.cancelled();

  @override
  Future<void> signOut() async {}
}
