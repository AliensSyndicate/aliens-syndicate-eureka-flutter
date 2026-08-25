# Skin do Eureka

## Direção

Dark, moderna, playful, limpa e adequada de crianças a adolescentes. Inspiração de categoria não autoriza copiar outra marca. Clareza vem antes de decoração.

## Tokens

- Cores: `UiColor`; fundo base `#2D2636`, acento principal `#D38DFD`, cores por matéria via `UiColor.forSubject`.
- Tipografia: `UiText`/`UiTypography`; UI em pt-BR, frases curtas e naturais.
- Geometria: `UiSize`, `UiSpacing`, `UiRadius`, `UiBorders`.
- Movimento: `UiMotion`, respeitando redução de animações.
- Ícones: `UiIcon`, flat/arredondados e consistentes; não misturar famílias incompatíveis.

## Componentes

- Reutilizar `NavigationApp`, `AppBottomSheet`, `AppButton`, campos de busca, skeletons, estados vazios/erro/retry, indicadores e avatar.
- Mensagens e decisões importantes usam exclusivamente `AppBottomSheet`; não usar `AlertDialog`.
- AppBars exibem apenas contexto e ações essenciais. Home: somente logo e XP.
- Loading usa skeleton ou animação contextual; evitar spinner grande e texto técnico.
- Erros são texto simples, sem ícone/borda/background desnecessários.
- Controles de resposta das atividades não usam ícones decorativos internos; preserve letras, números e rótulos necessários para compreender ou operar a atividade.
- O feedback de atividade entra no lugar de `Verificar`: ícone e título ficam fora dos controles de resposta; no acerto da jornada, ícone de XP e `+20 XP` aparecem à direita; em erro, resposta correta e justificativa aparecem abaixo.
- Evitar cards, bordas, badges e textos redundantes quando espaçamento e hierarquia resolvem.

## Acessibilidade

Toque mínimo de 48 px, contraste, semântica, escala de texto, foco previsível, estados não comunicados apenas por cor, alternativa para áudio e suporte à redução de movimento.
