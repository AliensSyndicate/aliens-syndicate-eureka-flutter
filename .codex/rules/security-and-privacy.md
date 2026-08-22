# Segurança e privacidade

Esta regra materializa as exigências do Documento Mestre para segurança, LGPD e proteção de menores. Não substitui revisão jurídica.

- Colete somente dados necessários para aprendizagem e operação do produto.
- Não publique progresso, respostas, identidade, e-mail ou outros dados pessoais em leitura pública.
- Comentários livres, mensagens, uploads e conteúdo público produzido por menores ficam fora da V1.
- Autenticação real deve usar Google e Apple quando aplicável. Não criar fluxo fictício de e-mail e senha.
- Pages e widgets não acessam Firebase ou Hive. Toda autorização, validação e persistência passa por services e repositories.
- Firestore Rules e validações de backend são obrigatórias; validação apenas no cliente não é proteção suficiente.
- App Check, ambientes separados e testes das regras são gates de lançamento remoto, não elementos decorativos.
- Exclusão, retenção, consentimento, termos e política de privacidade exigem decisão explícita e revisão jurídica antes de liberar conta real.
- Analytics não pode registrar enunciados, respostas livres, nomes, e-mails ou outros conteúdos pessoais desnecessários.
- Mocks e usuários fictícios devem ser identificáveis como teste e nunca apresentados como atividade social real.
