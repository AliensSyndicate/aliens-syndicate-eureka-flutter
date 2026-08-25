import '../models/auth/model_auth_result.dart';

abstract interface class AuthRepository {
  Stream<bool> get authenticationChanges;
  bool get isAuthenticated;
  String? get providerLabel;
  Future<bool> isAppleSignInAvailable();
  Future<void> reconcileSession();
  Future<AuthResult> signIn(AuthProvider provider);
  Future<void> signOut();
}
