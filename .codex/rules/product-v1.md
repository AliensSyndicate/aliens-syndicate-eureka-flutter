# Produto V1

Esta regra define o recorte da release atual e deve ser lida com `product-master.md`.

- O app abre diretamente com `local_test_user`, sem onboarding ou login falso. O estudo básico continua sem conta; criar ou entrar com Google/Apple é opcional para salvar o progresso.
- O catálogo remoto publicado atualmente cobre o 5º ano; a arquitetura permanece aberta aos demais anos e nunca deve codificar o 5º ano como limite permanente.
- A jornada curricular concede 20 XP por atividade correta pelo serviço central, com 5 atividades e máximo de 100 XP por aula. Antes de iniciar, mostrar `Ganhe até 100 XP`; em andamento ou concluída, mostrar `+{valor ganho} XP`. Explorar e Revisão não concedem XP. Simulado avalia sem farming.
- Na jornada, `Verificar` é substituído pelo feedback inline depois do envio. Acerto mostra `Correto!`; erro mostra `Errado!`, resposta correta e justificativa. Controles de resposta não usam ícones decorativos internos.
- O resumo da jornada mostra `+20 XP` em cada acerto, soma da aula e XP total. Hive persiste sempre; Firebase recebe o agregado somente para conta autenticada.
- O extrato lista apenas atividades respondidas. Repetir limpa a tentativa e volta à Atividade 1 sem limpar o registro de XP já concedido; uma mesma atividade nunca concede XP duas vezes.
- Social real permanece bloqueado enquanto autenticação Google/Apple, privacidade e backend não estiverem prontos. Mocks são apenas para testes e desenvolvimento.
- Não criar chat, posts manuais, comentários, anúncios, monetização, vidas, energia, loja, streak ou coleta desnecessária.
