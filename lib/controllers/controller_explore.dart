import 'dart:async';

import '../data/local/hive_explore_history.dart';
import '../data/local/hive_explore_recents.dart';
import '../enums/explore_state.dart';
import '../interfaces/repository_search.dart';
import '../models/content/model_content_manifest.dart';
import '../models/explore/model_search_filter.dart';
import '../models/explore/model_search_result.dart';
import '../models/model_lesson.dart';
import 'package:flutter/foundation.dart';

/// Controller do módulo Explorar.
///
/// Gerencia debounce, cancelamento de respostas antigas, histórico (Hive)
/// e estado da tela. A UI observa via [ListenableBuilder].
class ExploreController extends ChangeNotifier {
  ExploreController({
    required SearchRepository repository,
    required HiveExploreHistory history,
    required HiveExploreRecents recents,
  }) : _repository = repository,
       _history = history,
       _recents = recents;

  final SearchRepository _repository;
  final HiveExploreHistory _history;
  final HiveExploreRecents _recents;

  // ── Estado público ─────────────────────────────────────────────────────────

  ExploreState state = ExploreState.idle;
  String query = '';
  List<SearchResult> results = const [];
  SearchFilter? activeFilter;
  List<String> recentSearches = const [];
  List<Lesson> recentLessons = const [];
  List<SubjectContentManifest> subjects = const [];
  Object? error;

  // ── Controle interno ───────────────────────────────────────────────────────

  Timer? _debounce;

  /// Token incremental para cancelar respostas antigas.
  int _searchToken = 0;

  // ── Inicialização ──────────────────────────────────────────────────────────

  /// Deve ser chamado uma vez após a construção do controller.
  Future<void> init({List<Lesson>? allLessons}) async {
    recentSearches = _history.read();
    final recentIds = _recents.read();

    if (recentIds.isNotEmpty && allLessons != null) {
      // Reconstrói a lista de lessons recentes a partir dos IDs
      final lessonMap = {for (final l in allLessons) l.id: l};
      recentLessons = recentIds
          .map((id) => lessonMap[id])
          .whereType<Lesson>()
          .toList();
    }

    try {
      subjects = await _repository.getSubjects();
    } on Object catch (e) {
      error = e;
    }
    notifyListeners();
  }

  // ── Busca ──────────────────────────────────────────────────────────────────

  /// Chamado a cada tecla digitada. Aplica debounce de 300ms.
  void onQueryChanged(String value) {
    query = value;
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      state = ExploreState.idle;
      results = const [];
      notifyListeners();
      return;
    }

    state = ExploreState.typing;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 300), () => _doSearch());
  }

  /// Executa a busca imediatamente (ex.: ao pressionar o botão search).
  Future<void> searchNow() async {
    _debounce?.cancel();
    await _doSearch();
  }

  Future<void> _doSearch() async {
    if (query.trim().isEmpty) return;

    final token = ++_searchToken;
    state = ExploreState.loading;
    notifyListeners();

    try {
      final found = await _repository.search(query, filter: activeFilter);

      // Descarta se uma busca mais recente já foi iniciada.
      if (token != _searchToken) return;

      results = found;
      state = found.isEmpty ? ExploreState.empty : ExploreState.loaded;
    } on Object catch (e) {
      if (token != _searchToken) return;
      error = e;
      state = ExploreState.error;
    }

    notifyListeners();
  }

  // ── Histórico ──────────────────────────────────────────────────────────────

  /// Repete uma busca recente ao tocar em um chip de histórico.
  void repeatSearch(String savedQuery) {
    query = savedQuery;
    _debounce?.cancel();
    _doSearch();
  }

  /// Remove todo o histórico de queries.
  Future<void> clearHistory() async {
    await _history.clear();
    recentSearches = const [];
    notifyListeners();
  }

  // ── Filtros ────────────────────────────────────────────────────────────────

  /// Aplica ou remove filtros e re-executa a busca.
  Future<void> applyFilter(SearchFilter? filter) async {
    activeFilter = filter;
    if (query.trim().isNotEmpty) {
      await searchNow();
    } else {
      notifyListeners();
    }
  }

  // ── Acesso a conteúdo ──────────────────────────────────────────────────────

  /// Registra que o usuário acessou uma lesson pelo Explorar.
  Future<void> recordLessonAccess(Lesson lesson) async {
    // Grava histórico de recentes
    await _recents.add(lesson.id);
    // Grava query no histórico
    if (query.trim().isNotEmpty) {
      await _history.add(query.trim());
      recentSearches = _history.read();
    }
    // Atualiza lista de recentes em memória
    if (!recentLessons.any((l) => l.id == lesson.id)) {
      recentLessons = [lesson, ...recentLessons];
    }
    notifyListeners();
  }

  // ── Limpa estado ──────────────────────────────────────────────────────────

  void clearQuery() {
    _debounce?.cancel();
    _searchToken++;
    query = '';
    results = const [];
    state = ExploreState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
