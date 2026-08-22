# Dados, offline e sincronização

- Hive guarda usuário anônimo, preferências, progresso, histórico, sessões, buscas, configurações, cache e futura fila de sincronização.
- Firebase `eureka-9675a` fornece conteúdo publicado com fallback seed. Carregar sob demanda e preparar tudo antes de sessões imersivas.
- Sessão iniciada deve continuar offline sempre que os dados necessários estiverem locais.
- Sync futuro segue fila local → repository → Firebase → confirmação/retry. Conflitos pedagógicos usam política explícita; nunca `last write wins` acidental.
- Dados reais de usuário ficam bloqueados até autenticação Google/Apple e revisão LGPD.
- Widgets/pages nunca conhecem SDKs de persistência.
