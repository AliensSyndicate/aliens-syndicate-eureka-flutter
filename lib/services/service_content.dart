import '../data/local/hive_content_activity_cache.dart';
import '../data/local/hive_content_manifest_cache.dart';
import '../config/config_product.dart';
import '../data/seed/seed_content.dart';
import '../data/seed/seed_content_manifest.dart';
import '../enums/question_type.dart';
import '../interfaces/repository_content.dart';
import '../models/content/model_content_manifest.dart';
import '../models/model_lesson.dart';
import '../models/model_matching_pair.dart';
import '../models/model_question.dart';
import '../models/content/model_activity_reference.dart';
import 'service_question_selection.dart';

class ContentService {
  static const _downloadTimeout = Duration(seconds: 4);

  ContentService(
    this._remoteRepository,
    this._manifestCache,
    this._activityCache,
  ) : _manifest = _newestManifest(
        _manifestCache.read(),
        buildSeedContentManifest(),
      );
  final ContentRepository? _remoteRepository;
  final HiveContentManifestCache _manifestCache;
  final HiveContentActivityCache _activityCache;
  final Map<String, Future<Map<String, dynamic>?>> _downloads = {};
  ContentManifest _manifest;

  int get contentVersion => _manifest.contentVersion;

  Future<bool> syncManifest() async {
    if (_remoteRepository == null) return false;
    try {
      final remote = await _remoteRepository.fetchManifest();
      if (remote == null ||
          remote.contentVersion <= _manifest.contentVersion ||
          !_isValid(remote)) {
        return false;
      }
      await _manifestCache.write(remote);
      _manifest = remote;
      return true;
    } on Object {
      return false;
    }
  }

  Future<List<Lesson>> loadJourneyLessons() async {
    await syncManifest();
    return getJourneyLessons();
  }

  Future<List<SubjectContentManifest>> loadSubjectsForYear(int year) async {
    await syncManifest();
    return getSubjectsForYear(year);
  }

  Future<List<SubjectContentManifest>> loadSubjects() async {
    await syncManifest();
    return getSubjects();
  }

  List<Lesson> getJourneyLessons() => List.unmodifiable(
    _manifest
        .lessonsForYear(ProductConfig.v1SchoolYear)
        .where((lesson) => lesson.hasActivity),
  );

  List<SubjectContentManifest> getSubjectsForYear(int year) =>
      List.unmodifiable(_manifest.subjectsForYear(year));

  List<SubjectContentManifest> getSubjects() =>
      List.unmodifiable(_manifest.subjectsForYear(ProductConfig.v1SchoolYear));

  List<Lesson> search(String query) {
    final value = query.trim().toLowerCase();
    final lessons = getJourneyLessons();
    if (value.isEmpty) return lessons;
    return lessons
        .where(
          (lesson) =>
              '${lesson.title} ${lesson.summary}'.toLowerCase().contains(value),
        )
        .toList();
  }

  Future<Lesson> loadActivity(Lesson lesson) async {
    if (lesson.questions.isNotEmpty) return Future.value(lesson);
    if (lesson.activities.isEmpty && lesson.activityId == null) return lesson;
    final references = lesson.activities.isNotEmpty
        ? ([...lesson.activities]..sort((a, b) => a.order.compareTo(b.order)))
        : [
            ActivityReference(
              id: lesson.activityId ?? '${lesson.id}_v1',
              version: lesson.activityVersion,
            ),
          ];
    final payloads = (await Future.wait(
      references.map(_loadActivityPayload),
    )).whereType<Map<String, dynamic>>().toList();
    if (payloads.isNotEmpty) {
      final loaded = _lessonWithPayloads(lesson, payloads);
      if (loaded.questions.isNotEmpty) return loaded;
    }
    for (final reference in references) {
      final seedId = reference.id.replaceFirst(RegExp(r'_v\d+$'), '');
      for (final seed in seedLessons) {
        if (seed.id == seedId) {
          return _lessonWithSeed(lesson, seed);
        }
      }
    }
    return lesson;
  }

  Future<Map<String, dynamic>?> _loadActivityPayload(
    ActivityReference reference,
  ) {
    return _downloads.putIfAbsent(
      reference.id,
      () => _fetchActivityPayload(reference).whenComplete(() {
        _downloads.remove(reference.id);
      }),
    );
  }

  Future<Map<String, dynamic>?> _fetchActivityPayload(
    ActivityReference reference,
  ) async {
    var payload = _activityCache.read(reference.id, reference.version);
    if (!_isValidActivityPayload(payload, reference)) payload = null;
    if (payload == null && _remoteRepository != null) {
      try {
        payload = await _remoteRepository
            .fetchActivity(reference.id)
            .timeout(_downloadTimeout, onTimeout: () => null);
        if (_isValidActivityPayload(payload, reference)) {
          await _activityCache.write(reference.id, reference.version, payload!);
        } else {
          payload = null;
        }
      } on Object {
        payload = null;
      }
    }
    return payload;
  }

  bool _isValidActivityPayload(
    Map<String, dynamic>? payload,
    ActivityReference reference,
  ) =>
      payload != null &&
      payload['id'] == reference.id &&
      payload['activityVersion'] == reference.version;

  Lesson _lessonWithPayloads(
    Lesson lesson,
    List<Map<String, dynamic>> payloads,
  ) {
    final questions = payloads
        .expand(
          (payload) => (payload['questions'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .where((raw) {
                if (raw['enabled'] == false) return false;
                // Questões multipleChoice devem ter exatamente 4 alternativas.
                if (raw['type'] == 'multipleChoice') {
                  final opts = raw['options'] as List?;
                  return opts != null && opts.length == 4;
                }
                // Questões matching devem ter exatamente 5 pares.
                if (raw['type'] == 'matching') {
                  final prs = raw['pairs'] as List?;
                  return prs != null && prs.length == 5;
                }
                return true;
              })
              .map((raw) {
                final map = Map<String, dynamic>.from(raw);
                final type = QuestionType.values.byName(map['type'] as String);

                // Parseia pares para questões de ligação.
                List<MatchingPair>? pairs;
                if (type == QuestionType.matching) {
                  pairs = (map['pairs'] as List)
                      .whereType<Map>()
                      .map(
                        (p) => MatchingPair(
                          left: p['left'] as String,
                          right: p['right'] as String,
                        ),
                      )
                      .toList();
                }

                return Question(
                  id: map['id'] as String,
                  prompt: map['prompt'] as String,
                  type: type,
                  options: List<String>.from(
                    map['options'] as List? ?? const [],
                  ),
                  correctAnswer: map['correctAnswer'] as String,
                  explanation: map['explanation'] as String? ?? '',
                  subjectId: map['subjectId'] as String,
                  topicId: map['topicId'] as String,
                  pairs: pairs,
                  difficulty: map['difficulty'] as int? ?? 1,
                  tags: List<String>.from(map['tags'] as List? ?? const []),
                  version: map['version'] as int? ?? 1,
                );
              }),
        )
        .toList();
    final uniqueQuestionIds = questions.map((question) => question.id).toSet();
    if (questions.length < QuestionSelectionService.poolSize ||
        uniqueQuestionIds.length != questions.length) {
      return lesson;
    }
    return Lesson(
      id: lesson.id,
      title: lesson.title,
      summary: payloads.first['summary'] as String? ?? lesson.summary,
      subject: lesson.subject,
      questions: questions,
      schoolYear: lesson.schoolYear,
      topicId: lesson.topicId,
      skillId: lesson.skillId,
      prerequisiteLessonIds: lesson.prerequisiteLessonIds,
      activityId: lesson.activityId,
      activityVersion: lesson.activityVersion,
      activityChecksum: lesson.activityChecksum,
      activities: lesson.activities,
    );
  }

  Lesson _lessonWithSeed(Lesson lesson, Lesson seed) => Lesson(
    id: lesson.id,
    title: lesson.title,
    summary: seed.summary,
    subject: lesson.subject,
    questions: seed.questions,
    schoolYear: lesson.schoolYear,
    topicId: lesson.topicId,
    skillId: lesson.skillId,
    prerequisiteLessonIds: lesson.prerequisiteLessonIds,
    activityId: lesson.activityId,
    activityVersion: lesson.activityVersion,
    activityChecksum: lesson.activityChecksum,
    activities: lesson.activities,
  );

  bool _isValid(ContentManifest manifest) {
    if (manifest.schemaVersion != 1 || manifest.locale != 'pt-BR') return false;
    final lessons = manifest.subjects
        .expand((subject) => subject.schoolYears)
        .expand((year) => year.lessons)
        .toList();
    final ids = lessons.map((lesson) => lesson.id).toSet();
    return lessons.isNotEmpty &&
        ids.length == lessons.length &&
        lessons.every(
          (lesson) =>
              lesson.activities.every((activity) => activity.id.isNotEmpty),
        );
  }
}

ContentManifest _newestManifest(
  ContentManifest? cached,
  ContentManifest bundled,
) {
  if (cached == null || cached.contentVersion < bundled.contentVersion) {
    return bundled;
  }
  return cached;
}
