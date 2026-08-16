/// Par de itens para o exercício de ligação.
class MatchingPair {
  const MatchingPair({required this.left, required this.right});

  /// Item exibido na coluna esquerda.
  final String left;

  /// Item exibido na coluna direita (resposta correta de [left]).
  final String right;
}
