# Eureka

Aplicativo educacional gamificado para o ensino básico brasileiro. A V1 funciona sem login, com usuário temporário e progresso local em Hive.

## Execução

```bash
flutter pub get
flutter run
```

O projeto Firebase configurado é `eureka-9675a`. Conteúdo publicado é consultado no Firestore e o app usa seeds locais automaticamente quando estiver offline ou quando a coleção estiver vazia.

## Qualidade

```bash
flutter analyze
flutter test
```

Requisitos de produto e engenharia estão em `.codex/rules/`; os agentes especializados estão em `.agents/`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
