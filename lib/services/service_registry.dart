import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/repository_firestore_content.dart';
import '../repositories/repository_firestore_report.dart';
import '../repositories/repository_firestore_progress.dart';
import '../repositories/repository_firebase_auth.dart';
import '../repositories/repository_unavailable_auth.dart';
import '../repositories/repository_local_search.dart';
import '../data/local/hive_content_manifest_cache.dart';
import '../data/local/hive_content_activity_cache.dart';
import '../data/local/hive_explore_history.dart';
import '../data/local/hive_explore_recents.dart';
import '../data/local/hive_simulation_repository.dart';
import '../data/local/hive_progress_repository.dart';
import '../data/local/hive_user_repository.dart';
import '../data/local/hive_preferences_repository.dart';
import 'service_progress.dart';
import 'service_user.dart';
import 'service_answer.dart';
import 'service_content.dart';
import 'service_scoring.dart';
import 'service_simulation.dart';
import 'service_firebase.dart';
import 'service_recommendation.dart';
import 'service_question_selection.dart';
import 'service_report.dart';
import 'service_preferences.dart';
import 'service_auth.dart';
import '../interfaces/repository_auth.dart';
import '../interfaces/service_analytics.dart';

/// Ponto único de composição das dependências locais da V1.
abstract final class ServiceRegistry {
  static Box<dynamic> get _box => Hive.box<dynamic>('eureka');
  static Box<dynamic> get _contentBox => Hive.box<dynamic>('content_cache_v1');
  static UserService get user => UserService(HiveUserRepository(_box));
  static ProgressService get progress => ProgressService(
    HiveProgressRepository(_box, userId: user.loadCurrentUser().id),
    cloudRepository: FirebaseService.isAvailable
        ? FirestoreProgressRepository(
            FirebaseFirestore.instance,
            FirebaseAuth.instance,
          )
        : null,
  );
  static PreferencesService get preferences => PreferencesService(
    HivePreferencesRepository(_box, userId: user.loadCurrentUser().id),
  );
  static AuthRepository? _auth;
  static AuthRepository get auth => _auth ??= FirebaseService.isAvailable
      ? FirebaseAuthRepository(AuthService(), HiveUserRepository(_box))
      : const UnavailableAuthRepository();
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
  static AnalyticsService get analytics => NoopAnalyticsService();
  static HiveSimulationRepository get simulationRepository =>
      HiveSimulationRepository(_box, userId: user.loadCurrentUser().id);
  static RecommendationService get recommendation => RecommendationService();
  static QuestionSelectionService get questionSelection =>
      QuestionSelectionService();
  static ReportService? _report;
  static ReportService get report => _report ??= ReportService(
    repository: FirebaseService.isAvailable
        ? FirestoreReportRepository(FirebaseFirestore.instance)
        : null,
    userService: user,
  );

  /// Repositório de busca do Explorar (implementação local).
  static LocalSearchRepository? _search;
  static LocalSearchRepository get search =>
      _search ??= LocalSearchRepository(content);

  /// Histórico de queries do Explorar (Hive).
  static HiveExploreHistory get exploreHistory =>
      HiveExploreHistory(_box, userId: user.loadCurrentUser().id);

  /// Lessons recentemente acessadas pelo Explorar (Hive).
  static HiveExploreRecents get exploreRecents =>
      HiveExploreRecents(_box, userId: user.loadCurrentUser().id);
}
