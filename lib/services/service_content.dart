import '../data/local/hive_content_activity_cache.dart';
import '../data/local/hive_content_manifest_cache.dart';
import '../data/codecs/content_activity_codec.dart';
import '../config/config_product.dart';
import '../data/seed/seed_content.dart';
import '../data/seed/seed_content_manifest.dart';
import '../interfaces/repository_content.dart';
import '../models/content/model_content_manifest.dart';
import '../models/model_lesson.dart';
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

  /// Busca em todos os anos do manifesto — usado exclusivamente pelo Explorar.
  ///
  /// Normaliza acentos para tolerar buscas como `fracao → Fração`.
  /// Os resultados são ordenados: correspondências do ano [preferredYear] primeiro.
  List<Lesson> searchAllLessons(
    String query, {
    int preferredYear = 5,
    String? subjectId,
    int? schoolYear,
  }) {
    final value = _normalize(query.trim());
    final all = _manifest.lessons;
    final filtered = all.where((lesson) {
      if (subjectId != null) {
        // Filtragem por matéria via nome da SubjectContentManifest não está
        // disponível direto no Lesson; usamos subject.name como proxy.
        final subjectMatch = lesson.subject.name == subjectId;
        if (!subjectMatch) return false;
      }
      if (schoolYear != null && lesson.schoolYear != schoolYear) return false;
      if (value.isEmpty) return true;
      final haystack = _normalize(
        '${lesson.title} ${lesson.summary} ${lesson.skills.join(' ')}',
      );
      return haystack.contains(value);
    }).toList();

    // Ordena: ano preferido primeiro, depois por título normalizado.
    filtered.sort((a, b) {
      final aPreferred = a.schoolYear == preferredYear ? 0 : 1;
      final bPreferred = b.schoolYear == preferredYear ? 0 : 1;
      final yearCmp = aPreferred.compareTo(bPreferred);
      if (yearCmp != 0) return yearCmp;
      return _normalize(a.title).compareTo(_normalize(b.title));
    });

    return filtered;
  }

  /// Retorna o nome da matéria para uma lesson, buscando no manifesto.
  String subjectNameForLesson(Lesson lesson) {
    for (final subject in _manifest.subjects) {
      if (subject.type == lesson.subject) return subject.title;
    }
    return lesson.subject.name;
  }

  /// Retorna todas as matérias do manifesto (todos os anos habilitados).
  List<SubjectContentManifest> getAllSubjects() =>
      List.unmodifiable(_manifest.sortedSubjects);

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[áàâãä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[íìîï]'), 'i')
      .replaceAll(RegExp('[óòôõö]'), 'o')
      .replaceAll(RegExp('[úùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll('ñ', 'n');

  int pageCountForLesson(Lesson lesson) {
    if (lesson.questions.isNotEmpty) {
      final contentPagesCount = lesson.contentPages.isEmpty
          ? 1
          : lesson.contentPages.length;
      return contentPagesCount + lesson.questions.length;
    }
    final references = lesson.activities.isNotEmpty
        ? lesson.activities
        : [
            ActivityReference(
              id: lesson.activityId ?? '${lesson.id}_v1',
              version: lesson.activityVersion,
            ),
          ];
    for (final reference in references) {
      final payload = _activityCache.read(reference.id, reference.version);
      if (payload != null && _isValidActivityPayload(payload, reference)) {
        final decoded = ContentActivityCodec.decode(payload);
        if (decoded != null) {
          final contentPagesCount = decoded.contentPages.isEmpty
              ? 1
              : decoded.contentPages.length;
          return contentPagesCount + decoded.questions.length;
        }
      }
      final seedId = reference.id.replaceFirst(RegExp(r'_v\d+$'), '');
      for (final seed in seedLessons) {
        if (seed.id == seedId) {
          final contentPagesCount = seed.contentPages.isEmpty
              ? 1
              : seed.contentPages.length;
          return contentPagesCount + seed.questions.length;
        }
      }
    }
    final contentPagesCount = lesson.contentPages.isEmpty
        ? 1
        : lesson.contentPages.length;
    return contentPagesCount + lesson.questions.length;
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
    final decoded = payloads
        .map(ContentActivityCodec.decode)
        .whereType<DecodedContentActivity>()
        .toList();
    final questions = decoded.expand((activity) => activity.questions).toList();
    final uniqueQuestionIds = questions.map((question) => question.id).toSet();
    if (questions.length < QuestionSelectionService.poolSize ||
        uniqueQuestionIds.length != questions.length) {
      return lesson;
    }
    return Lesson(
      id: lesson.id,
      title: lesson.title,
      summary: decoded.first.summary.isEmpty
          ? lesson.summary
          : decoded.first.summary,
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
      unit: decoded.first.unit,
      topic: decoded.first.topic,
      shortDescription: decoded.first.shortDescription,
      bnccCodes: decoded.first.bnccCodes,
      skills: decoded.first.skills,
      learningObjectives: decoded.first.learningObjectives,
      estimatedMinutes: decoded.first.estimatedMinutes,
      contentPages: decoded
          .expand((activity) => activity.contentPages)
          .toList(),
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
    unit: lesson.unit,
    topic: lesson.topic,
    shortDescription: lesson.shortDescription,
    bnccCodes: lesson.bnccCodes,
    skills: lesson.skills,
    learningObjectives: lesson.learningObjectives,
    estimatedMinutes: lesson.estimatedMinutes,
    contentPages: lesson.contentPages,
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
