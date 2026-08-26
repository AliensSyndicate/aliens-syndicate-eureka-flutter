import 'package:eureka/controllers/controller_auth.dart';
import 'package:eureka/enums/login_context.dart';
import 'package:eureka/interfaces/repository_auth.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/auth/model_auth_result.dart';
import 'package:eureka/models/auth/model_login_request.dart';
import 'package:eureka/pages/auth/widget_login_content.dart';
import 'package:eureka/pages/auth/page_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PageAuth é tela cheia bloqueante', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PageAuth(
          controller: AuthController(_FakeAuthRepository(apple: false)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(PopScope), findsOneWidget);
    expect(find.text(AppStrings.continueWithoutAccount), findsNothing);
  });

  testWidgets('autenticação obrigatória não permite continuar sem conta', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginContent(
            request: const LoginRequest(context: LoginContext.saveProgress),
            controller: AuthController(_FakeAuthRepository(apple: false)),
            onAuthenticated: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.continueWithGoogle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(AppStrings.authCreateOrSignIn), findsOneWidget);
    expect(find.text(AppStrings.continueWithApple.toUpperCase()), findsNothing);
    expect(find.text(AppStrings.continueWithoutAccount), findsNothing);
  });

  testWidgets('contexto Social não oferece saída de progresso', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginContent(
            request: const LoginRequest(context: LoginContext.social),
            controller: AuthController(_FakeAuthRepository(apple: true)),
            onAuthenticated: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.continueWithApple.toUpperCase()),
      findsOneWidget,
    );
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
