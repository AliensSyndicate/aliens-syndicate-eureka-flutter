import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/navigation/navigation_router.dart';
import '../../controllers/controller_explore.dart';
import '../../enums/explore_state.dart';
import '../../enums/subject_type.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/explore/model_search_filter.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import '../subject/page_subject.dart';
import 'widgets/widget_continue_learning_section.dart';
import 'widgets/widget_explore_empty.dart';
import 'widgets/widget_explore_skeleton.dart';
import 'widgets/widget_recent_searches.dart';
import 'widgets/widget_search_bar.dart';
import 'widgets/widget_search_result_list.dart';
import 'widgets/widget_subject_shortcuts.dart';

class PageExplore extends StatefulWidget {
  const PageExplore({super.key});

  @override
  State<PageExplore> createState() => _PageExploreState();
}

class _PageExploreState extends State<PageExplore> {
  late final ExploreController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExploreController(
      repository: ServiceRegistry.search,
      history: ServiceRegistry.exploreHistory,
      recents: ServiceRegistry.exploreRecents,
    );
    // Inicializa com todas as lessons para reconstruir a lista de recentes
    final allLessons = ServiceRegistry.content.searchAllLessons('');
    _controller.init(allLessons: allLessons);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Cabeçalho + busca ─────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(
          UiSpacing.pageHorizontal,
          UiSpacing.md,
          UiSpacing.pageHorizontal,
          UiSpacing.sm,
        ),
        child: ExploreSearchBar(
          initialValue: _controller.query,
          onChanged: _controller.onQueryChanged,
          onSubmitted: _controller.searchNow,
          onClear: _controller.clearQuery,
        ),
      ),
      // ── Corpo reativo ─────────────────────────────────────────────────────
      Expanded(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _body(context),
        ),
      ),
    ],
  );

  Widget _body(BuildContext context) {
    final state = _controller.state;

    return switch (state) {
      ExploreState.idle || ExploreState.typing => _initialContent(),
      ExploreState.loading => const ExploreSkeleton(),
      ExploreState.loaded => _resultContent(context),
      ExploreState.empty => const ExploreEmpty(),
      ExploreState.error => const ExploreEmpty(),
    };
  }

  // ── Estado inicial (idle / typing) ─────────────────────────────────────────

  Widget _initialContent() => ListView(
    padding: const EdgeInsets.only(bottom: UiSpacing.pageVertical),
    children: [
      // Continuar estudando
      if (_controller.recentLessons.isNotEmpty) ...[
        ContinueLearningSection(
          lessons: _controller.recentLessons,
          onTap: _openLesson,
        ),
        const SizedBox(height: UiSpacing.sectionSpacing),
      ],
      // Buscas recentes
      if (_controller.recentSearches.isNotEmpty) ...[
        RecentSearches(
          queries: _controller.recentSearches,
          onTap: _controller.repeatSearch,
          onClear: _controller.clearHistory,
        ),
        const SizedBox(height: UiSpacing.sectionSpacing),
      ],
      // Atalhos por matéria
      if (_controller.subjects.isNotEmpty)
        SubjectShortcuts(subjects: _controller.subjects, onTap: _openSubject),
    ],
  );

  // ── Resultados ─────────────────────────────────────────────────────────────

  Widget _resultContent(BuildContext context) => SingleChildScrollView(
    child: SearchResultList(
      results: _controller.results,
      filter: _controller.activeFilter,
      onTap: (result) => _openLesson(result.lesson),
      onFilterTap: () => _showFilterSheet(context),
      onRemoveSubjectFilter: () =>
          _controller.applyFilter(_controller.activeFilter?.withoutSubject()),
      onRemoveYearFilter: () =>
          _controller.applyFilter(_controller.activeFilter?.withoutYear()),
    ),
  );

  // ── Ações ──────────────────────────────────────────────────────────────────

  Future<void> _openLesson(Lesson lesson) async {
    await _controller.recordLessonAccess(lesson);
    if (!mounted) return;

    final activity = await ServiceRegistry.content.loadActivity(lesson);
    if (!mounted) return;

    if (activity.questions.isEmpty && activity.contentPages.isEmpty) {
      await AppBottomSheet.show<void>(
        context,
        title: lesson.title,
        content: const Text(AppStrings.contentUnavailable),
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }

    await context.pushNamed(
      AppRoute.lesson,
      extra: LessonRouteArguments(
        lesson: activity,
        mode: LearningMode.explore, // sem XP
      ),
    );
  }

  Future<void> _openSubject(SubjectContentManifest subject) => showSubjectSheet(
    context,
    subject: subject,
    schoolYear: subject.schoolYears.isNotEmpty
        ? subject.schoolYears.first.year
        : 5,
  );

  // ── Filtros (AppBottomSheet) ───────────────────────────────────────────────

  Future<void> _showFilterSheet(BuildContext context) async {
    await AppBottomSheet.show<void>(
      context,
      title: AppStrings.exploreFilterSubject,
      content: _FilterSheetContent(
        subjects: _controller.subjects,
        currentFilter: _controller.activeFilter,
        onApply: (filter) {
          Navigator.pop(context);
          _controller.applyFilter(filter);
        },
      ),
    );
  }
}

// ── Filter Sheet ───────────────────────────────────────────────────────────────

class _FilterSheetContent extends StatefulWidget {
  const _FilterSheetContent({
    required this.subjects,
    required this.currentFilter,
    required this.onApply,
  });

  final List<SubjectContentManifest> subjects;
  final SearchFilter? currentFilter;
  final ValueChanged<SearchFilter?> onApply;

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  SubjectType? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.currentFilter?.subject;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(AppStrings.exploreFilterSubject, style: UiText.label),
      const SizedBox(height: UiSpacing.sm),
      // Opção "Todas"
      _Option(
        label: AppStrings.exploreFilterAll,
        selected: _selectedSubject == null,
        onTap: () => setState(() => _selectedSubject = null),
      ),
      ...widget.subjects.map(
        (s) => _Option(
          label: s.title,
          selected: _selectedSubject == s.type,
          onTap: () => setState(() => _selectedSubject = s.type),
        ),
      ),
      const SizedBox(height: UiSpacing.lg),
      AppButton(
        label: 'Aplicar filtro',
        onPressed: () => widget.onApply(
          _selectedSubject == null
              ? null
              : SearchFilter(subject: _selectedSubject),
        ),
      ),
    ],
  );
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: UiSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: UiText.p.copyWith(
                color: selected ? UiColor.accent : UiColor.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check, color: UiColor.accent, size: 20),
        ],
      ),
    ),
  );
}
