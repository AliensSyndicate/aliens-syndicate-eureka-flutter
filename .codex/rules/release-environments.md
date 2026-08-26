# Ambientes e observabilidade

- Use `--dart-define=EUREKA_ENV=development|staging|production` para identificar o ambiente.
- Firebase pode ser desligado com `EUREKA_FIREBASE_ENABLED=false` somente em testes e desenvolvimento controlado; sem Auth disponível, o produto permanece no gate de autenticação e não libera a experiência local.
- Analytics, App Check e Crash Reporting ficam desligados por padrão até que projetos, credenciais, consentimento e pipelines sejam configurados para cada ambiente.
- Nunca reutilize silenciosamente o projeto Firebase de produção em development ou staging.
- A promoção para produção exige arquivos Firebase próprios, Firestore Rules testadas, App Check válido, política de privacidade aprovada e testes em dispositivo.
- Chaves e arquivos de credenciais não entram no repositório por conveniência.
