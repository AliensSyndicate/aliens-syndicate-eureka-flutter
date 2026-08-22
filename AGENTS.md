# Instruções do projeto Eureka

Trate `.codex/rules/product-master.md`, `.codex/rules/` e `.codex/skin.md` como fonte de verdade. `product-v1.md` define apenas o recorte da release atual. Código e identificadores em inglês; comentários e documentação em português; UI em pt-BR via recursos centralizados.

Para criação, revisão ou publicação de conteúdo pedagógico do 5º ano, siga integralmente `.codex/rules/content-grade5.md`. Em caso de conflito, `.codex/rules/product-master.md` define o produto, `.codex/rules/product-v1.md` define o recorte da entrega atual e a regra de conteúdo define o contrato pedagógico e estrutural.

- Não acesse Firebase ou Hive em pages/widgets; use services e repositories.
- Toda regra de negócio deve ficar no service responsável. Pontuação fica em `service_scoring.dart`.
- Reutilize tokens `ui_*` e componentes `app_*`; não hardcode estilos ou mensagens nas pages.
- Use exclusivamente `AppBottomSheet` para comunicação modal.
- Preserve a ordem Home, Social, Explorar, Simulado e Profile.
- Não amplie o escopo de produto sem decisão explícita.
- Adicione testes para regras de domínio relevantes.

Consulte os agentes especializados em `.agents/` quando o trabalho tocar seus domínios.
