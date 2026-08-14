import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/repository_firestore_content.dart';
import 'service_progress.dart';
import 'service_user.dart';
import 'service_answer.dart';
import 'service_content.dart';
import 'service_scoring.dart';
import 'service_simulation.dart';
import 'service_firebase.dart';

/// Ponto único de composição das dependências locais da V1.
abstract final class ServiceRegistry {
  static Box<dynamic> get _box => Hive.box<dynamic>('eureka');
  static UserService get user => UserService(_box);
  static ProgressService get progress => ProgressService(_box);
  static AnswerService get answer => AnswerService();
  static ContentService? _content;
  static ContentService get content => _content ??= ContentService(
    FirebaseService.isAvailable
        ? FirestoreContentRepository(FirebaseFirestore.instance)
        : null,
  );
  static ScoringService get scoring => ScoringService();
  static SimulationService get simulation => SimulationService();
}
