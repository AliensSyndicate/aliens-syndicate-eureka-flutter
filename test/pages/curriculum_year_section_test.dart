import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/models/content/model_content_manifest.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/pages/subject/widgets/widget_curriculum_year_section.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trilha recebe altura finita dentro de uma lista', (
    tester,
  ) async {
    final lesson = Lesson(
      id: 'mathematics_ef_1_1',
      title: 'Contagem e números naturais',
      summary: '',
      subject: SubjectType.mathematics,
      questions: const [],
    );
    final year = SubjectSchoolYearManifest(
      id: 'mathematics_ef_1',
      year: 1,
      title: '1º ano EF',
      order: 0,
      lessons: [lesson],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              CurriculumYearSection(
                year: year,
                color: UiColor.mathematics,
                completedLessonIds: const {},
                onLessonTap: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Contagem e números naturais'), findsOneWidget);
    expect(find.text('0%'), findsNWidgets(2));
  });
}
