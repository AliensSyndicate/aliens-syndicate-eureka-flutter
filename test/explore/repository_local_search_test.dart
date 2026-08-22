import 'dart:io';

import 'package:eureka/data/local/hive_content_activity_cache.dart';
import 'package:eureka/data/local/hive_content_manifest_cache.dart';

import 'package:eureka/models/explore/model_search_filter.dart';
import 'package:eureka/repositories/repository_local_search.dart';
import 'package:eureka/services/service_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late LocalSearchRepository repo;
  late Directory tempDir;
  late Box<dynamic> box;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('eureka_search_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('search_test');
  });

  setUp(() {
    box.clear();
    final content = ContentService(
      null, // sem repositório remoto
      HiveContentManifestCache(box),
      HiveContentActivityCache(box),
    );
    repo = LocalSearchRepository(content);
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  group('search — resultados', () {
    test('query vazia retorna todas as lessons com atividade', () async {
      final results = await repo.search('');
      expect(results, isNotEmpty);
    });

    test('busca exata por título retorna resultado correspondente', () async {
      final all = await repo.search('');
      if (all.isEmpty) return; // seed vazia, skip

      final title = all.first.title;
      final results = await repo.search(title);
      expect(results.any((r) => r.title == title), isTrue);
    });

    test('query sem correspondência retorna lista vazia', () async {
      final results = await repo.search('zzzzzzqueryinexistente9999');
      expect(results, isEmpty);
    });

    test(
      'normalização: busca sem acento encontra resultado com acento',
      () async {
        final all = await repo.search('');
        // Procura uma lesson que contenha título com acento
        final withAccent = all
            .where((r) => r.title.contains(RegExp('[àáâãäèéêëìíîïòóôõöùúûü]')))
            .toList();

        if (withAccent.isEmpty) return; // seed sem acentos, skip

        final normalized = withAccent.first.title
            .toLowerCase()
            .replaceAll(RegExp('[áàâãä]'), 'a')
            .replaceAll(RegExp('[éèêë]'), 'e')
            .replaceAll(RegExp('[íìîï]'), 'i')
            .replaceAll(RegExp('[óòôõö]'), 'o')
            .replaceAll(RegExp('[úùûü]'), 'u')
            .replaceAll('ç', 'c');

        final results = await repo.search(normalized);
        expect(
          results.any(
            (r) =>
                r.title.toLowerCase() == withAccent.first.title.toLowerCase(),
          ),
          isTrue,
        );
      },
    );
  });

  group('search — filtros', () {
    test('filtro por matéria retorna apenas resultados da matéria', () async {
      final all = await repo.search('');
      if (all.isEmpty) return;

      // Usa a matéria do primeiro resultado
      final subject = all.first.subjectType;
      final filtered = await repo.search(
        '',
        filter: SearchFilter(subject: subject),
      );
      expect(filtered.every((r) => r.subjectType == subject), isTrue);
    });

    test('filtro por ano retorna apenas resultados do ano', () async {
      final all = await repo.search('');
      if (all.isEmpty) return;

      final year = all.first.schoolYear;
      final filtered = await repo.search(
        '',
        filter: SearchFilter(schoolYear: year),
      );
      expect(filtered.every((r) => r.schoolYear == year), isTrue);
    });
  });

  group('getSubjects', () {
    test('retorna lista de matérias não vazia', () async {
      final subjects = await repo.getSubjects();
      expect(subjects, isNotEmpty);
    });
  });
}
