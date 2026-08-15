import 'package:flutter/material.dart';
import '../../controllers/controller_home.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import '../subject/page_subject_lessons.dart';
import 'widgets/widget_subject_card.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});
  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late final int schoolYear;
  late final Future<List<SubjectContentManifest>> subjects;

  @override
  void initState() {
    super.initState();
    schoolYear = ServiceRegistry.user.loadCurrentUser().schoolYear;
    subjects = HomeController(ServiceRegistry.content).loadSubjects(schoolYear);
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<SubjectContentManifest>>(
        future: subjects,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.pageHorizontal,
              vertical: UiSpacing.pageVertical,
            ),
            children: [
              Text(AppStrings.subjectsTitle, style: UiText.h2),
              const SizedBox(height: UiSpacing.sm),
              const Text(AppStrings.journeySubtitle),
              const SizedBox(height: UiSpacing.sectionSpacing),
              ...items.map((subject) {
                final progress = ServiceRegistry.progress.completionPercentage(
                  subject.lessonsForYear(schoolYear),
                );
                return SubjectCard(
                  subject: subject,
                  progress: progress,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PageSubjectLessons(
                          subject: subject,
                          schoolYear: schoolYear,
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                );
              }),
            ],
          );
        },
      );
}
