import 'dart:async';

import 'package:eureka/controllers/controller_auth.dart';
import 'package:eureka/interfaces/repository_auth.dart';
import 'package:eureka/models/auth/model_auth_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cancelamento volta a deixar as ações disponíveis sem erro', () async {
    final controller = AuthController(
      _FakeAuthRepository(const AuthResult.cancelled()),
    );

    final authenticated = await controller.signIn(AuthProvider.google);

    expect(authenticated, isFalse);
    expect(controller.status, AuthStatus.cancelled);
    expect(controller.isBusy, isFalse);
    expect(controller.message, isNull);
  });

  test('erro humano fica disponível para nova tentativa', () async {
    final controller = AuthController(
      _FakeAuthRepository(const AuthResult.error('Sem conexão no momento.')),
    );

    await controller.signIn(AuthProvider.apple);

    expect(controller.status, AuthStatus.error);
    expect(controller.message, 'Sem conexão no momento.');
    expect(controller.loadingProvider, isNull);
  });

  test(
    'ignora segundo toque enquanto a autenticação está em andamento',
    () async {
      final repository = _PendingAuthRepository();
      final controller = AuthController(repository);

      final first = controller.signIn(AuthProvider.google);
      final second = await controller.signIn(AuthProvider.google);

      expect(second, isFalse);
      expect(repository.signInCalls, 1);
      repository.complete(const AuthResult.authenticated());
      expect(await first, isTrue);
    },
  );
}

class _PendingAuthRepository implements AuthRepository {
  final _result = Completer<AuthResult>();
  int signInCalls = 0;

  void complete(AuthResult result) => _result.complete(result);

  @override
  Stream<bool> get authenticationChanges => const Stream.empty();

  @override
  bool get isAuthenticated => false;

  @override
  String? get providerLabel => null;

  @override
  Future<bool> isAppleSignInAvailable() async => false;

  @override
  Future<void> reconcileSession() async {}

  @override
  Future<AuthResult> signIn(AuthProvider provider) {
    signInCalls++;
    return _result.future;
  }

  @override
  Future<void> signOut() async {}
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.result);

  final AuthResult result;

  @override
  Stream<bool> get authenticationChanges => const Stream.empty();

  @override
  bool get isAuthenticated => false;

  @override
  String? get providerLabel => null;

  @override
  Future<bool> isAppleSignInAvailable() async => true;

  @override
  Future<void> reconcileSession() async {}

  @override
  Future<AuthResult> signIn(AuthProvider provider) async => result;

  @override
  Future<void> signOut() async {}
}
