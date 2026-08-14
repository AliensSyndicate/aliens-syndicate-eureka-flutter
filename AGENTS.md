# Instruções do projeto Eureka

Trate a especificação da V1 e `.codex/rules/` como fonte de verdade. Código e identificadores em inglês; comentários e documentação em português; UI em pt-BR via recursos centralizados.

- Não acesse Firebase ou Hive em pages/widgets; use services e repositories.
- Toda regra de negócio deve ficar no service responsável. Pontuação fica em `service_scoring.dart`.
- Reutilize tokens `ui_*` e componentes `app_*`; não hardcode estilos ou mensagens nas pages.
- Use exclusivamente `AppBottomSheet` para comunicação modal.
- Preserve a ordem Home, Social, Explorar, Simulado e Profile.
- Não amplie o escopo de produto sem decisão explícita.
- Adicione testes para regras de domínio relevantes.

Consulte os agentes especializados em `.agents/` quando o trabalho tocar seus domínios.
