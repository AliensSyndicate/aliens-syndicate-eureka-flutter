import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/auth/model_auth_result.dart';

class AuthIdentity {
  const AuthIdentity({required this.uid, required this.provider});

  final String uid;
  final AuthProvider provider;
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  bool _googleInitialized = false;

  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  Future<bool> isAppleSignInAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } on Object {
      return false;
    }
  }

  Future<AuthIdentity?> signInWithGoogle() async {
    try {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize();
        _googleInitialized = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const FormatException('missing-id-token');
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      return user == null
          ? null
          : AuthIdentity(uid: user.uid, provider: AuthProvider.google);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      rethrow;
    }
  }

  Future<AuthIdentity?> signInWithApple() async {
    final rawNonce = _nonce();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );
    final idToken = credential.identityToken;
    if (idToken == null) throw const FormatException('missing-id-token');
    final oauthCredential = AppleAuthProvider.credentialWithIDToken(
      idToken,
      rawNonce,
      AppleFullPersonName(),
    );
    final result = await _firebaseAuth.signInWithCredential(oauthCredential);
    final user = result.user;
    return user == null
        ? null
        : AuthIdentity(uid: user.uid, provider: AuthProvider.apple);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (_googleInitialized) await GoogleSignIn.instance.signOut();
  }

  String _nonce() {
    const characters =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      32,
      (_) => characters[random.nextInt(characters.length)],
    ).join();
  }
}
