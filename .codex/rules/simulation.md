# Simulado

Precedência: `product-v1.md` define escopo/economia; `content-grade5.md` define catálogo pedagógico; esta regra define o comportamento avaliativo. Regras transversais continuam válidas.

- Fluxo: configurar → confirmar/preparar → responder/revisar → finalizar/expirar → resultado → revisão.
- Configuração exige matéria, conteúdo, quantidade válida e duração definida. “Sem limite” permanece pendente.
- Gerar exatamente N questões únicas quando houver capacidade, equilibrando primeiro matérias e depois conteúdos. Pool insuficiente nunca reduz silenciosamente.
- Usar questões autossuficientes `simulatorExplore` e tipos avaliáveis; reutilizar `Question`, `AnswerService` e a engine visual.
- Durante a prova: sem `NavigationApp`, XP ou feedback de correção; permitir pular, voltar e marcar revisão.
- Tempo restante deriva de `endTime`, nunca somente de decremento em memória. Expiração/finalização são idempotentes.
- Persistir por repository versionado: configuração, snapshot das questões, início/fim, índice, respostas, marcações e status. Após iniciar, funcionar offline.
- Persistir resultado concluído antes de remover a sessão ativa. Sync remoto futuro não bloqueia resultado local.
- Resultado satisfaz acertos + erros + brancos = total; tempo é secundário; mostrar matéria/conteúdo e permitir revisão com resposta escolhida, correta e explicação.
- V1 concede 0 XP e não escreve em ranking/social.
- Testar capacidade, balanceamento, unicidade, timer/background, corrupção/restauração, concorrência, resultado, revisão, ausência de feedback e acessibilidade.
