import 'package:hive_flutter/hive_flutter.dart';

/// Persiste o histórico de queries digitadas no Explorar.
///
/// Usa o box Hive `eureka` já aberto na inicialização do app.
class HiveExploreHistory {
  HiveExploreHistory(this._box, {String? userId}) : _userId = userId;
  final Box<dynamic> _box;
  final String? _userId;

  static const _key = 'explore_recent_queries';
  static const _maxItems = 5;
  String get _scopedKey => _userId == null ? _key : 'user.$_userId.$_key';

  /// Retorna as últimas queries em ordem cronológica reversa (mais recente primeiro).
  List<String> read() {
    final stored = _box.get(_scopedKey);
    if (stored is! List) return const [];
    return List<String>.from(stored.reversed);
  }

  /// Adiciona [query] ao histórico, removendo duplicatas e respeitando o limite.
  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final current = List<String>.from(
      _box.get(_scopedKey) as List? ?? const [],
    );
    // Remove duplicata se existir
    current.remove(trimmed);
    current.add(trimmed);
    // Mantém apenas os últimos _maxItems
    final capped = current.length > _maxItems
        ? current.sublist(current.length - _maxItems)
        : current;
    await _box.put(_scopedKey, capped);
  }

  /// Remove todo o histórico.
  Future<void> clear() => _box.delete(_scopedKey);
}
