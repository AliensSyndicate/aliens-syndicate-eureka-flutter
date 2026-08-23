import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../interfaces/repository_auth.dart';
import '../interfaces/repository_user.dart';
import '../models/auth/model_auth_result.dart';
import '../models/model_user.dart';
import '../services/service_auth.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._service, this._users);

  final AuthService _service;
  final UserRepository _users;

  @override
  Stream<bool> get authenticationChanges =>
      _service.userChanges.map((user) => user != null).distinct();

  @override
  bool get isAuthenticated => _service.currentUser != null;

  @override
  String? get providerLabel {
    final providers = _service.currentUser?.providerData;
    if (providers == null) return null;
    if (providers.any((provider) => provider.providerId == 'apple.com')) {
      return 'Apple';
    }
    if (providers.any((provider) => provider.providerId == 'google.com')) {
      return 'Google';
    }
    return null;
  }

  @override
  Future<bool> isAppleSignInAvailable() => _service.isAppleSignInAvailable();

  @override
  Future<AuthResult> signIn(AuthProvider provider) async {
    try {
      final identity = switch (provider) {
        AuthProvider.google => await _service.signInWithGoogle(),
        AuthProvider.apple => await _service.signInWithApple(),
      };
      if (identity == null) return const AuthResult.cancelled();
      final local = _users.loadCurrentUser();
      await _users.saveCurrentUser(
        AppUser(
          id: identity.uid,
          displayName: local?.displayName ?? 'Explorador',
          schoolYear: local?.schoolYear ?? 5,
          isTemporary: false,
        ),
      );
      return const AuthResult.authenticated();
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.cancelled();
      }
      return AuthResult.error(_messageFor(error));
    } on FirebaseAuthException catch (error) {
      return AuthResult.error(_messageFor(error));
    } on GoogleSignInException catch (error) {
      return AuthResult.error(_messageFor(error));
    } on Object catch (error) {
      return AuthResult.error(_messageFor(error));
    }
  }

  @override
  Future<void> signOut() async {
    final local = _users.loadCurrentUser();
    await _service.signOut();
    await _users.saveCurrentUser(
      AppUser(
        id: 'local_test_user',
        displayName: local?.displayName ?? 'Explorador',
        schoolYear: local?.schoolYear ?? 5,
        isTemporary: true,
      ),
    );
  }

  String _messageFor(Object error) {
    if (error is FirebaseAuthException) {
      if (error.code == 'network-request-failed') {
        return 'Sem conexão no momento.';
      }
      if (error.code == 'account-exists-with-different-credential' ||
          error.code == 'credential-already-in-use') {
        return 'Esta conta já está conectada de outra forma.';
      }
    }
    return 'Não conseguimos entrar agora.';
  }
}
