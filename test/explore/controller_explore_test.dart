import 'dart:io';

import 'package:eureka/controllers/controller_explore.dart';
import 'package:eureka/data/local/hive_explore_history.dart';
import 'package:eureka/data/local/hive_explore_recents.dart';
import 'package:eureka/enums/explore_state.dart';
import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/interfaces/repository_search.dart';
import 'package:eureka/models/content/model_content_manifest.dart';
import 'package:eureka/models/explore/model_search_filter.dart';
import 'package:eureka/models/explore/model_search_result.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('eureka_ctrl_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('ctrl_test');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  ExploreController makeController({
    List<SearchResult>? results,
    bool throwOnSearch = false,
  }) {
    box.clear();
    return ExploreController(
      repository: _FakeSearchRepository(
        results: results ?? _defaultResults,
        throwOnSearch: throwOnSearch,
      ),
      history: HiveExploreHistory(box),
      recents: HiveExploreRecents(box),
    );
  }

  group('Estado inicial', () {
    test('começa em idle', () {
      final ctrl = makeController();
      expect(ctrl.state, ExploreState.idle);
    });

    test('query inicial é vazia', () {
      final ctrl = makeController();
      expect(ctrl.query, '');
    });

    test('resultados iniciais são vazios', () {
      final ctrl = makeController();
      expect(ctrl.results, isEmpty);
    });
  });

  group('Busca', () {
    test('onQueryChanged com texto muda estado para typing', () {
      final ctrl = makeController();
      ctrl.onQueryChanged('fração');
      expect(ctrl.state, ExploreState.typing);
      ctrl.dispose();
    });

    test('query vazia volta para idle e limpa resultados', () {
      final ctrl = makeController();
      ctrl.onQueryChanged('fração');
      ctrl.onQueryChanged('');
      expect(ctrl.state, ExploreState.idle);
      expect(ctrl.results, isEmpty);
      ctrl.dispose();
    });

    test('searchNow executa busca imediatamente', () async {
      final ctrl = makeController();
      // A query precisa corresponder ao título do resultado fake ("Frações")
      ctrl.query = 'Frações';
      await ctrl.searchNow();
      expect(ctrl.state, ExploreState.loaded);
      expect(ctrl.results, isNotEmpty);
      ctrl.dispose();
    });

    test('busca sem correspondência resulta em empty', () async {
      final ctrl = makeController(results: const []);
      ctrl.query = 'inexistente';
      await ctrl.searchNow();
      expect(ctrl.state, ExploreState.empty);
      ctrl.dispose();
    });

    test('erro de busca resulta em error state', () async {
      final ctrl = makeController(throwOnSearch: true);
      ctrl.query = 'fração';
      await ctrl.searchNow();
      expect(ctrl.state, ExploreState.error);
      ctrl.dispose();
    });
  });

  group('Debounce', () {
    test('múltiplas teclas rápidas resultam em uma única busca', () async {
      var searchCount = 0;
      final repo = _CountingRepository(onSearch: () => searchCount++);
      final ctrl = ExploreController(
        repository: repo,
        history: HiveExploreHistory(box),
        recents: HiveExploreRecents(box),
      );

      ctrl.onQueryChanged('f');
      ctrl.onQueryChanged('fr');
      ctrl.onQueryChanged('fra');
      ctrl.onQueryChanged('fração');

      // Espera o debounce (300ms + margem)
      await Future<void>.delayed(const Duration(milliseconds: 450));

      expect(searchCount, 1);
      ctrl.dispose();
    });
  });

  group('Histórico', () {
    test('searchNow salva query no histórico', () async {
      final ctrl = makeController();
      ctrl.query = 'fração';
      await ctrl.searchNow();
      await ctrl.recordLessonAccess(_defaultLesson);

      expect(ctrl.recentSearches, contains('fração'));
      ctrl.dispose();
    });

    test('clearHistory remove buscas recentes', () async {
      final ctrl = makeController();
      ctrl.query = 'fração';
      await ctrl.searchNow();
      await ctrl.recordLessonAccess(_defaultLesson);
      await ctrl.clearHistory();

      expect(ctrl.recentSearches, isEmpty);
      ctrl.dispose();
    });

    test('repeatSearch define query e inicia busca', () async {
      final ctrl = makeController();
      ctrl.repeatSearch('matemática');

      await Future<void>.delayed(const Duration(milliseconds: 450));

      expect(ctrl.query, 'matemática');
      ctrl.dispose();
    });
  });

  group('Filtros', () {
    test('applyFilter reexecuta busca com filtro ativo', () async {
      final ctrl = makeController();
      ctrl.query = 'qualquer';
      await ctrl.applyFilter(
        const SearchFilter(subject: SubjectType.mathematics),
      );
      expect(ctrl.activeFilter?.subject, SubjectType.mathematics);
      ctrl.dispose();
    });

    test('applyFilter null remove filtro', () async {
      final ctrl = makeController();
      await ctrl.applyFilter(null);
      expect(ctrl.activeFilter, isNull);
      ctrl.dispose();
    });
  });

  group('Recentes', () {
    test('recordLessonAccess adiciona lesson à lista de recentes', () async {
      final ctrl = makeController();
      ctrl.query = 'fração';
      await ctrl.searchNow();
      await ctrl.recordLessonAccess(_defaultLesson);

      expect(ctrl.recentLessons.any((l) => l.id == _defaultLesson.id), isTrue);
      ctrl.dispose();
    });
  });

  group('clearQuery', () {
    test('limpa query e volta para idle', () {
      final ctrl = makeController();
      ctrl.onQueryChanged('fração');
      ctrl.clearQuery();
      expect(ctrl.query, '');
      expect(ctrl.state, ExploreState.idle);
      ctrl.dispose();
    });
  });
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

final _defaultLesson = Lesson(
  id: 'math_fractions_1',
  title: 'Frações',
  summary: 'Aprenda frações',
  subject: SubjectType.mathematics,
  questions: const [],
  schoolYear: 5,
);

final _defaultResults = [SearchResult.fromLesson(_defaultLesson, 'Matemática')];

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({required this.results, this.throwOnSearch = false});

  final List<SearchResult> results;
  final bool throwOnSearch;

  @override
  Future<List<SearchResult>> search(
    String query, {
    SearchFilter? filter,
  }) async {
    if (throwOnSearch) throw Exception('Erro simulado');
    if (query.trim().isEmpty) return results;
    return results
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<SubjectContentManifest>> getSubjects() async => const [];
}

class _CountingRepository implements SearchRepository {
  _CountingRepository({required this.onSearch});
  final VoidCallback onSearch;

  @override
  Future<List<SearchResult>> search(
    String query, {
    SearchFilter? filter,
  }) async {
    onSearch();
    return const [];
  }

  @override
  Future<List<SubjectContentManifest>> getSubjects() async => const [];
}

typedef VoidCallback = void Function();
