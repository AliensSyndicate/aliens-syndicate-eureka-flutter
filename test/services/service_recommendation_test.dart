import 'package:eureka/data/seed/seed_content_manifest.dart';
import 'package:eureka/services/service_recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recomenda a matéria com maior dificuldade registrada', () {
    final manifest = buildSeedContentManifest();
    final result = RecommendationService().recommend(
      manifest.subjectsForYear(5),
      5,
      {'science': 3, 'mathematics': 1},
    );
    expect(result?.subject.id, 'science');
  });
}
