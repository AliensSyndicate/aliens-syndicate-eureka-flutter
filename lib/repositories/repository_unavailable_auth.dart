import '../interfaces/repository_auth.dart';
import '../l10n/app_strings.dart';
import '../models/auth/model_auth_result.dart';

class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

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
  Future<AuthResult> signIn(AuthProvider provider) async =>
      const AuthResult.error(AppStrings.authUnavailable);

  @override
  Future<void> signOut() async {}
}
