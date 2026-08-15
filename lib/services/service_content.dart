import '../data/local/hive_content_activity_cache.dart';
import '../data/local/hive_content_manifest_cache.dart';
import '../data/seed/seed_content.dart';
import '../data/seed/seed_content_manifest.dart';
import '../enums/question_type.dart';
import '../interfaces/repository_content.dart';
import '../models/content/model_content_manifest.dart';
import '../models/model_lesson.dart';
import '../models/model_question.dart';
import '../models/content/model_activity_reference.dart';

class ContentService {
  ContentService(
    this._remoteRepository,
    this._manifestCache,
    this._activityCache,
  ) : _manifest = _manifestCache.read() ?? buildSeedContentManifest();
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

  List<Lesson> getJourneyLessons() =>
      List.unmodifiable(_manifest.lessonsForYear(5));

  List<SubjectContentManifest> getSubjectsForYear(int year) =>
      List.unmodifiable(_manifest.subjectsForYear(year));

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
    if (payloads.isNotEmpty) return _lessonWithPayloads(lesson, payloads);
    return seedLessons.firstWhere(
      (seed) => seed.id == lesson.id,
      orElse: () => lesson,
    );
  }

  Future<Map<String, dynamic>?> _loadActivityPayload(
    ActivityReference reference,
  ) => _downloads.putIfAbsent(
    reference.id,
    () => _fetchActivityPayload(
      reference,
    ).whenComplete(() => _downloads.remove(reference.id)),
  );

  Future<Map<String, dynamic>?> _fetchActivityPayload(
    ActivityReference reference,
  ) async {
    var payload = _activityCache.read(reference.id, reference.version);
    if (payload == null && _remoteRepository != null) {
      try {
        payload = await _remoteRepository.fetchActivity(reference.id);
        if (payload != null) {
          await _activityCache.write(reference.id, reference.version, payload);
        }
      } on Object {
        payload = null;
      }
    }
    return payload;
  }

  Lesson _lessonWithPayloads(
    Lesson lesson,
    List<Map<String, dynamic>> payloads,
  ) {
    final questions = payloads
        .expand(
          (payload) => (payload['questions'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map((raw) {
                final map = Map<String, dynamic>.from(raw);
                return Question(
                  id: map['id'] as String,
                  prompt: map['prompt'] as String,
                  type: QuestionType.values.byName(map['type'] as String),
                  options: List<String>.from(
                    map['options'] as List? ?? const [],
                  ),
                  correctAnswer: map['correctAnswer'] as String,
                  subjectId: map['subjectId'] as String,
                  topicId: map['topicId'] as String,
                  difficulty: map['difficulty'] as int? ?? 1,
                  tags: List<String>.from(map['tags'] as List? ?? const []),
                  version: map['version'] as int? ?? 1,
                );
              }),
        )
        .toList();
    if (questions.isEmpty) return lesson;
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
              lesson.activities.isNotEmpty &&
              lesson.activities.every((activity) => activity.id.isNotEmpty),
        );
  }
}
