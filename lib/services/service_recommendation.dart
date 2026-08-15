import '../models/content/model_content_manifest.dart';
import '../models/model_learning_recommendation.dart';

class RecommendationService {
  LearningRecommendation? recommend(
    List<SubjectContentManifest> subjects,
    int schoolYear,
    Map<String, int> difficultyScores,
  ) {
    final candidates = subjects
        .where((subject) => subject.lessonsForYear(schoolYear).isNotEmpty)
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final score = (difficultyScores[b.id] ?? 0).compareTo(
        difficultyScores[a.id] ?? 0,
      );
      if (score != 0) return score;
      if (a.id == 'mathematics') return -1;
      if (b.id == 'mathematics') return 1;
      return a.title.compareTo(b.title);
    });
    final subject = candidates.first;
    return LearningRecommendation(
      subject: subject,
      lesson: subject.lessonsForYear(schoolYear).first,
    );
  }
}
