abstract final class AppStrings {
  static const appName = 'Eureka',
      greeting = 'Olá, Explorador!',
      subjectsTitle = 'Matérias',
      continueWhereStopped = 'Continuar de onde parou',
      recommendedForYou = 'Recomendado para você',
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
      checkAnswer = 'Verificar',
      nextQuestion = 'Continuar',
      finish = 'Concluir',
      correctFeedback = 'Muito bem!',
      correctTitle = 'Correto!',
      correctFeedbackMessage = 'Muito bem! Continue explorando no seu ritmo.',
      incorrectTitle = 'Incorreto!',
      incorrectFeedback = 'Quase! Leve essa ideia para a próxima.',
      correctAnswer = 'Resposta correta',
      answerExplanation = 'Entenda por quê',
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
      loadingContent = 'Carregando conteúdo',
      preparingActivity = 'Preparando sua atividade',
      lessonLoadingTitle = "A chama do conhecimento\nestá acesa.",
      lessonCampfireIllustration =
          'Ilustração de uma chama acesa sobre dois troncos.',
      comingSoon = 'Em breve',
      closeActivity = 'Fechar atividade',
      back = 'Voltar',
      reportError = 'Reportar erro',
      reportErrorUnavailable = 'O envio de relatos estará disponível em breve.',
      lessonContent = 'Conteúdo',
      playLessonAudio = 'Ouvir conteúdo da aula',
      pauseLessonAudio = 'Pausar leitura da aula',
      completeAllLessons = 'Complete todas as aulas',
      lessonElapsedTimeLabel = 'Tempo decorrido da aula',
      lessonPaginationLabel = 'Página da atividade',
      lessonTimeUp = 'O tempo da aula terminou',
      lessonTimeUpMessage = 'Os 20 minutos acabaram. Você pode tentar esta lição novamente.',
      answeredActivity = 'Atividade respondida',
      currentActivity = 'Atividade atual',
      returnToCurrentActivity = 'Voltar à atividade atual',
      matchingPrompt = 'Toque os pares correspondentes',
      matchingComplete = 'Todos os pares conectados!',
      orderingPrompt = 'Monte a frase na ordem correta',
      essayHint = 'Escreva sua explicação...',
      sequencingPrompt = 'Arraste os itens para a ordem correta',
      trueLabel = 'Verdadeiro',
      falseLabel = 'Falso',
      memoryPrompt = 'Encontre os pares!',
      memoryComplete = 'Todos os pares encontrados!';
  static String lessonPage(int current, int total, String label) =>
      '$current de $total - $label';
  static const xpLabel = 'Pontos de experiência';
  static const levelLabel = 'Nível atual';
  static String xpValue(int value) => '$value XP';
  static String levelValue(int value) => 'Você está no nível $value.';

  static String schoolYear(int year) => '$yearº ano';
  static String level(int value) => 'Nível $value';
  static String completedLessons(int value) =>
      value == 1 ? '1 lição concluída' : '$value lições concluídas';
  static String recommendationReason(String lesson) =>
      'Reforce $lesson e avance com confiança.';
  static String activityPosition(int current, int total) =>
      'Atividade $current de $total';
  static String correctAnswerValue(String answer) => '$correctAnswer\n$answer';
  static String essayCounter(int length, int maxLength) => '$length/$maxLength';
  static String memoryPairs(int found, int total) => '$found/$total';
  static String lessonTime(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String lessonElapsedTime(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '${minutes}m${seconds}s';
  }

  static String lessonPagination(int current, int total) {
    final page = current.clamp(1, total).toString().padLeft(2, '0');
    final pageTotal = total.toString().padLeft(2, '0');
    return 'pag. $page/$pageTotal';
  }
}
