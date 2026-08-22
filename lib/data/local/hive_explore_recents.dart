import 'package:hive_flutter/hive_flutter.dart';

/// Persiste IDs de lessons acessadas recentemente via Explorar.
///
/// Permite exibir a seção "Continuar estudando" na tela inicial.
class HiveExploreRecents {
  HiveExploreRecents(this._box);
  final Box<dynamic> _box;

  static const _key = 'explore_recent_lessons';
  static const _maxItems = 10;

  /// Retorna os IDs de lessons mais recentes (mais recente primeiro).
  List<String> read() {
    final stored = _box.get(_key);
    if (stored is! List) return const [];
    return List<String>.from(stored.reversed);
  }

  /// Registra acesso a uma lesson pelo Explorar.
  Future<void> add(String lessonId) async {
    final current = List<String>.from(_box.get(_key) as List? ?? const []);
    current.remove(lessonId);
    current.add(lessonId);
    final capped = current.length > _maxItems
        ? current.sublist(current.length - _maxItems)
        : current;
    await _box.put(_key, capped);
  }

  /// Remove todo o histórico de recentes.
  Future<void> clear() => _box.delete(_key);
}
