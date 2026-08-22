# Testes

- Unit tests cobrem domínio; widget tests cobrem estados/interação; integration tests cobrem fluxos críticos; repositories usam fakes/mocks controlados.
- Cobrir pontuação, progresso, retomada/versionamento, seleção de questões, resultado/revisão, offline e privacidade.
- Fluxos críticos: currículo completo, ponto a melhorar, fechar/reabrir aula, Explorar preservando busca, Simulado em background, Social com rollback e conclusão offline.
- Widgets cobrem `loading`, `loaded`, `empty`, `offline`, `error`, `retry`, escala de texto, semântica e toque mínimo.
- Toda correção de regressão inclui teste quando viável. Antes de concluir: `dart format`, `flutter analyze`, `flutter test` e `git diff --check`.
