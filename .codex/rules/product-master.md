# Documento mestre do Eureka

Fonte normativa: `Eureka_Documento_Mestre_Produto_UX_Arquitetura_IA.docx`, versão 1.0, agosto de 2026.

## Hierarquia

- Decisões obrigatórias viram regras e testes de regressão.
- Padrões viram skin, componentes e convenções reutilizáveis.
- Pendências nunca são decididas silenciosamente por código ou agents; devem permanecer configuráveis ou marcadas como `PENDENTE DE PRODUTO`.
- `.codex/rules/product-v1.md` define o recorte da release atual, sem anular a arquitetura e as regras obrigatórias deste documento.
- `.codex/rules/content-grade5.md` define o contrato do conteúdo pedagógico de 5º ano publicado atualmente.

## Produto

- O Eureka atende do 1º ano do Ensino Fundamental ao 3º ano do Ensino Médio. Ano organiza e recomenda, mas não bloqueia conteúdo publicado.
- Ordem da navegação: Home, Social, Explorar, Simulado e Profile.
- Estudo básico funciona sem login. Social, Amigos, Ranking e sincronização entre dispositivos exigem autenticação Google ou Apple; não simular autenticação.
- Explorar não concede XP por padrão. Simulado não revela correção durante a prova e não concede XP para farming.
- Não implementar posts manuais, comentários livres, mensagens privadas, vidas, energia, moedas, loja, streak, missões ou mascote fixo sem decisão explícita.

## Fluxos

- Home mostra somente logo e XP na AppBar, continuidade real, ponto a melhorar quando houver evidência e matérias disponíveis.
- Fluxo curricular alvo: Matéria → Ano → Tópicos → Aula → Atividades → Resultado.
- Aulas usam introdução concreta/narrativa quando útil, explicação formal, exemplos e prática.
- Atividades normais usam `Verificar`, feedback por `AppBottomSheet` e não exibem cronômetro.
- Revisão, Explorar e Simulado reutilizam a mesma engine de atividades, variando contexto e regras.
- Simulado persiste sessão, calcula tempo por `endTime`, funciona offline após preparação, equilibra matérias/conteúdos e só corrige no resultado.
- Na jornada curricular, cada atividade respondida corretamente concede 20 XP. Cada aula possui 5 atividades da jornada e, portanto, oferece no máximo 100 XP.
- Antes de a aula ser iniciada, sua apresentação mostra `Ganhe até 100 XP`. Depois de iniciada, durante o andamento e após a conclusão, mostra `+{valor ganho} XP`, inclusive `+0 XP` quando ainda não houve acerto.

## Arquitetura e dados

- UI → controller/state → service/repository → datasource → Firebase/Hive.
- Pages e widgets não acessam Firebase ou Hive.
- Sessões iniciadas devem continuar com dados locais e preservar versões/ordem das questões.
- Conteúdo é data-driven e versionado; tipos, respostas, explicações e mídia são metadados estruturados.
- Dados de menores são mínimos. Nunca expor localização, telefone ou e-mail no Social.

## Pendências explícitas

Melhor nota versus última, thresholds de selos, Platina, streak, missões, economia, achievements amplos, regras exatas de domínio ainda não definidas, áudio/autoplay, notificações, favoritos, download manual, mascote fixo e modo responsável/pais.
