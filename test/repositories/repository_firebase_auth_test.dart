import 'package:eureka/interfaces/repository_user.dart';
import 'package:eureka/models/auth/model_auth_result.dart';
import 'package:eureka/models/model_user.dart';
import 'package:eureka/repositories/repository_firebase_auth.dart';
import 'package:eureka/services/service_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('primeiro acesso autentica e preserva o perfil local', () async {
    final gateway = _FakeAuthGateway();
    final users = _FakeUserRepository(
      const AppUser(
        id: 'local_test_user',
        displayName: 'Estudante',
        schoolYear: 6,
        isTemporary: true,
      ),
    );
    final repository = FirebaseAuthRepository(gateway, users);

    final result = await repository.signIn(AuthProvider.google);

    expect(result.status, AuthResultStatus.authenticated);
    expect(users.user?.id, 'firebase_uid');
    expect(users.user?.displayName, 'Estudante');
    expect(users.user?.schoolYear, 6);
    expect(users.user?.isTemporary, isFalse);
  });

  test('reconcilia sessão Firebase persistida com o Hive', () async {
    final gateway = _FakeAuthGateway()
      ..identity = const AuthIdentity(
        uid: 'firebase_uid',
        provider: AuthProvider.apple,
      );
    final users = _FakeUserRepository(null);
    final repository = FirebaseAuthRepository(gateway, users);

    await repository.reconcileSession();

    expect(users.user?.id, 'firebase_uid');
    expect(users.user?.isTemporary, isFalse);
    expect(repository.providerLabel, 'Apple');
  });

  test('remove autenticação local obsoleta sem sessão Firebase', () async {
    final gateway = _FakeAuthGateway();
    final users = _FakeUserRepository(
      const AppUser(
        id: 'old_uid',
        displayName: 'Estudante',
        schoolYear: 5,
        isTemporary: false,
      ),
    );
    final repository = FirebaseAuthRepository(gateway, users);

    await repository.reconcileSession();

    expect(users.user?.id, 'local_test_user');
    expect(users.user?.isTemporary, isTrue);
  });

  test(
    'desfaz sessão remota quando não consegue persistir o usuário',
    () async {
      final gateway = _FakeAuthGateway();
      final users = _FakeUserRepository(null)..failOnSave = true;
      final repository = FirebaseAuthRepository(gateway, users);

      final result = await repository.signIn(AuthProvider.google);

      expect(result.status, AuthResultStatus.error);
      expect(gateway.signOutCalls, 1);
    },
  );
}

class _FakeAuthGateway implements AuthGateway {
  AuthIdentity? identity;
  int signOutCalls = 0;

  @override
  Stream<bool> get authenticationChanges => const Stream.empty();

  @override
  AuthIdentity? get currentIdentity => identity;

  @override
  Future<bool> isAppleSignInAvailable() async => true;

  @override
  Future<AuthIdentity?> signInWithApple() async => _authenticate(
    const AuthIdentity(uid: 'firebase_uid', provider: AuthProvider.apple),
  );

  @override
  Future<AuthIdentity?> signInWithGoogle() async => _authenticate(
    const AuthIdentity(uid: 'firebase_uid', provider: AuthProvider.google),
  );

  AuthIdentity _authenticate(AuthIdentity value) {
    identity = value;
    return value;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    identity = null;
  }
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this.user);

  AppUser? user;
  bool failOnSave = false;

  @override
  AppUser? loadCurrentUser() => user;

  @override
  Future<void> saveCurrentUser(AppUser user) async {
    if (failOnSave) throw StateError('save failed');
    this.user = user;
  }
}
