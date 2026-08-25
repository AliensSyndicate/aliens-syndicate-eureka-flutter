# Dados, offline e sincronização

- Hive guarda usuário anônimo, preferências, progresso, histórico, sessões, buscas, configurações, cache e futura fila de sincronização.
- Firebase `eureka-9675a` fornece conteúdo publicado com fallback seed. Carregar sob demanda e preparar tudo antes de sessões imersivas.
- Sessão iniciada deve continuar offline sempre que os dados necessários estiverem locais.
- Progresso salva primeiro no Hive. Para conta Google/Apple autenticada, o repository também grava no caminho privado do usuário no Firebase; falha remota não desfaz a gravação local.
- A sincronização remota de progresso contém somente XP, IDs de aulas concluídas, resultado agregado e IDs das atividades que já concederam XP. Não enviar respostas individuais. Conflitos e restauração entre dispositivos exigem política explícita; nunca aplicar `last write wins` acidental.
- Dados reais de usuário permanecem bloqueados no Firebase sem autenticação Google/Apple.
- Widgets/pages nunca conhecem SDKs de persistência.
