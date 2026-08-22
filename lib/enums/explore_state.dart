/// Estados possíveis da tela de Explorar.
enum ExploreState {
  /// Estado inicial — antes de qualquer busca.
  idle,

  /// Usuário está digitando, debounce pendente.
  typing,

  /// Busca em andamento.
  loading,

  /// Busca concluída com resultados.
  loaded,

  /// Busca concluída sem resultados.
  empty,

  /// Erro de busca (ex.: falha de rede sem cache).
  error,
}
