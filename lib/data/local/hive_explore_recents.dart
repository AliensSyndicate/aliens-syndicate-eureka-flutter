import 'package:hive_flutter/hive_flutter.dart';

/// Persiste IDs de lessons acessadas recentemente via Explorar.
///
/// Permite exibir a seção "Continuar estudando" na tela inicial.
class HiveExploreRecents {
  HiveExploreRecents(this._box, {String? userId}) : _userId = userId;
  final Box<dynamic> _box;
  final String? _userId;

  static const _key = 'explore_recent_lessons';
  static const _maxItems = 10;
  String get _scopedKey => _userId == null ? _key : 'user.$_userId.$_key';

  /// Retorna os IDs de lessons mais recentes (mais recente primeiro).
  List<String> read() {
    final stored = _box.get(_scopedKey);
    if (stored is! List) return const [];
    return List<String>.from(stored.reversed);
  }

  /// Registra acesso a uma lesson pelo Explorar.
  Future<void> add(String lessonId) async {
    final current = List<String>.from(
      _box.get(_scopedKey) as List? ?? const [],
    );
    current.remove(lessonId);
    current.add(lessonId);
    final capped = current.length > _maxItems
        ? current.sublist(current.length - _maxItems)
        : current;
    await _box.put(_scopedKey, capped);
  }

  /// Remove todo o histórico de recentes.
  Future<void> clear() => _box.delete(_scopedKey);
}
