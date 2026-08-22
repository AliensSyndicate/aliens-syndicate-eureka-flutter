# Conteúdo e currículo

O Documento Mestre descreve uma arquitetura curricular do 1º ano do Ensino Fundamental ao 3º ano do Ensino Médio. A entrega V1 atual publica apenas o catálogo aprovado do 5º ano.

- A arquitetura deve permanecer orientada a dados e preparada para múltiplos anos; não codifique uma taxonomia exclusiva do 5º ano no domínio.
- Não exponha anos, matérias ou conteúdos sem uma versão publicada e validada.
- O ano do perfil recomenda e organiza. Quando outros anos forem publicados, não deve ser usado como bloqueio permanente de acesso.
- Na V1, `lesson` é a unidade editorial selecionável apresentada ao usuário como conteúdo. IDs técnicos como `topicId` nunca são labels de UI.
- Não invente uma nova árvore de unidades/tópicos sem contrato editorial e migração do manifesto.
- Toda atividade é estruturada, versionada, validada e carregada sob demanda com cache e fallback controlado.
- Para o 5º ano, `.codex/rules/content-grade5.md` continua sendo o contrato pedagógico obrigatório.
- Mídia deve evoluir por referências e blocos tipados, sem acoplar origem Firebase/asset aos widgets.
