import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import '../firebase_options.dart';
import '../config/config_environment.dart';

/// Inicializa o Firebase sem impedir a experiência offline da V1.
abstract final class FirebaseService {
  static bool isAvailable = false;

  static Future<void> initialize() async {
    if (!EnvironmentConfig.firebaseEnabled) {
      isAvailable = false;
      return;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isAvailable = true;
    } on FirebaseException {
      isAvailable = false;
    } on PlatformException {
      // O plugin pode não estar registrado após hot reload ou em testes.
      isAvailable = false;
    }
  }
}
