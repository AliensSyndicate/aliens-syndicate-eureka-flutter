import 'package:flutter/foundation.dart';

import '../interfaces/repository_auth.dart';
import '../models/auth/model_auth_result.dart';

enum AuthStatus { idle, loading, authenticated, error, cancelled }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;
  AuthStatus status = AuthStatus.idle;
  AuthProvider? loadingProvider;
  String? message;

  bool get isBusy => status == AuthStatus.loading;
  Future<bool> isAppleSignInAvailable() => _repository.isAppleSignInAvailable();

  Future<bool> signIn(AuthProvider provider) async {
    if (isBusy) return false;
    status = AuthStatus.loading;
    loadingProvider = provider;
    message = null;
    notifyListeners();
    final result = await _repository.signIn(provider);
    loadingProvider = null;
    status = switch (result.status) {
      AuthResultStatus.authenticated => AuthStatus.authenticated,
      AuthResultStatus.cancelled => AuthStatus.cancelled,
      AuthResultStatus.error => AuthStatus.error,
    };
    message = result.message;
    notifyListeners();
    return status == AuthStatus.authenticated;
  }
}
