import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/repository_firestore_content.dart';
import '../data/local/hive_content_manifest_cache.dart';
import '../data/local/hive_content_activity_cache.dart';
import 'service_progress.dart';
import 'service_user.dart';
import 'service_answer.dart';
import 'service_content.dart';
import 'service_scoring.dart';
import 'service_simulation.dart';
import 'service_firebase.dart';
import 'service_recommendation.dart';
import 'service_question_selection.dart';

/// Ponto único de composição das dependências locais da V1.
abstract final class ServiceRegistry {
  static Box<dynamic> get _box => Hive.box<dynamic>('eureka');
  static Box<dynamic> get _contentBox => Hive.box<dynamic>('content_cache_v1');
  static UserService get user => UserService(_box);
  static ProgressService get progress => ProgressService(_box);
  static AnswerService get answer => AnswerService();
  static ContentService? _content;
  static ContentService get content => _content ??= ContentService(
    FirebaseService.isAvailable
        ? FirestoreContentRepository(FirebaseFirestore.instance)
        : null,
    HiveContentManifestCache(_contentBox),
    HiveContentActivityCache(_contentBox),
  );
  static ScoringService get scoring => ScoringService();
  static SimulationService get simulation => SimulationService();
  static RecommendationService get recommendation => RecommendationService();
  // TODO: voltar para QuestionSelectionService() após validar os componentes.
  static QuestionSelectionService get questionSelection =>
      QuestionSelectionService(showcaseMode: true);
}
