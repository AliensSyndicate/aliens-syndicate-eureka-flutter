abstract final class AppStrings {
  static const appName = 'Eureka',
      greeting = 'Olá, Explorador!',
      subjectsTitle = 'Matérias',
      continueWhereStopped = 'Continuar de onde parou',
      journeySubtitle = 'Sua próxima descoberta está logo adiante.',
      home = 'Home',
      social = 'Social',
      explore = 'Explorar',
      simulation = 'Simulado',
      profile = 'Profile',
      socialSoon = 'Em breve, conquistas e desafios com amigos.',
      exploreHint = 'Busque uma matéria ou conteúdo',
      start = 'Começar',
      temporaryAccount = 'Conta temporária',
      selectToReview = 'Selecionar para revisar',
      lessonSummary = 'Antes de começar',
      startActivity = 'Começar atividade',
      checkAnswer = 'Conferir resposta',
      nextQuestion = 'Próxima pergunta',
      finish = 'Concluir',
      correctFeedback = 'Muito bem! Você encontrou a resposta.',
      incorrectFeedback = 'Quase! Leve essa ideia para a próxima.',
      correctAnswer = 'Resposta correta',
      lessonComplete = 'Descoberta concluída!',
      noXpOutsideJourney = 'Este modo é para estudar e não concede XP.',
      selectAtLeastOne = 'Selecione pelo menos um conteúdo.',
      startSimulation = 'Começar simulado',
      simulationResult = 'Resultado do simulado',
      reviewSuggestion = 'Vale revisar',
      strongPerformance = 'Ótimo domínio destes conteúdos!',
      emptyResults = 'Nenhum conteúdo encontrado.',
      contentUnavailable =
          'Esta atividade ainda não está disponível offline. Verifique sua conexão e tente novamente.',
      lessonProgress = 'Progresso da atividade';

  static String schoolYear(int year) => '$yearº ano';
  static String level(int value) => 'Nível $value';
  static String completedLessons(int value) =>
      value == 1 ? '1 lição concluída' : '$value lições concluídas';
}
