import 'dart:async';

import 'package:flutter/foundation.dart';

import '../interfaces/repository_auth.dart';

/// Mantém o gate global alinhado à sessão persistida pelo Firebase.
class AuthSessionController extends ChangeNotifier {
  AuthRepository? _repository;
  StreamSubscription<bool>? _subscription;
  bool _initialized = false;
  bool _isAuthenticated = false;

  bool get initialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> initialize(AuthRepository repository) async {
    _repository = repository;
    await repository.reconcileSession();
    _initialized = true;
    _isAuthenticated = repository.isAuthenticated;
    notifyListeners();
    _subscription = repository.authenticationChanges.listen((_) {
      unawaited(_reconcile());
    });
  }

  Future<void> _reconcile() async {
    final repository = _repository;
    if (repository == null) return;
    await repository.reconcileSession();
    final authenticated = repository.isAuthenticated;
    if (_initialized && authenticated == _isAuthenticated) return;
    _initialized = true;
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authSessionController = AuthSessionController();
