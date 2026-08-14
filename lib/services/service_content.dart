import '../data/seed/seed_content.dart';
import '../models/model_lesson.dart';
import '../interfaces/repository_content.dart';

/// Entrega conteúdo local e permite trocar a fonte por um repositório remoto.
class ContentService {
  ContentService([this._remoteRepository]);
  final ContentRepository? _remoteRepository;
  List<Lesson> _cachedLessons = seedLessons;

  Future<List<Lesson>> loadJourneyLessons() async {
    try {
      final remote = await _remoteRepository?.findPublishedLessons(
        schoolYear: 5,
      );
      if (remote != null && remote.isNotEmpty) {
        _cachedLessons = remote;
        return remote;
      }
    } on Object {
      // Falhas remotas usam o conteúdo seed sem interromper o estudo.
    }
    return getJourneyLessons();
  }

  List<Lesson> getJourneyLessons() => List.unmodifiable(_cachedLessons);
  List<Lesson> search(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return getJourneyLessons();
    return seedLessons
        .where(
          (lesson) =>
              '${lesson.title} ${lesson.summary}'.toLowerCase().contains(value),
        )
        .toList();
  }
}
