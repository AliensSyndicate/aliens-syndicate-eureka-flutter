import '../models/content/model_content_manifest.dart';
import '../models/explore/model_search_filter.dart';
import '../models/explore/model_search_result.dart';

/// Contrato de busca do Explorar.
///
/// A implementação concreta pode ser trocada para Algolia, Typesense
/// ou qualquer outro índice sem que a UI saiba.
abstract interface class SearchRepository {
  /// Retorna resultados para [query] com filtros opcionais.
  Future<List<SearchResult>> search(String query, {SearchFilter? filter});

  /// Retorna todas as matérias disponíveis para o grid de atalhos.
  Future<List<SubjectContentManifest>> getSubjects();
}
