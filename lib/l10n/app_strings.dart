import '../enums/question_type.dart';
import '../enums/subject_type.dart';

abstract final class AppStrings {
  static const appName = 'Eureka',
      subjectsTitle = 'Matérias',
      continueWhereStopped = 'Continuar de onde parou',
      recommendedForYou = 'Vale revisar',
      home = 'Home',
      social = 'Social',
      explore = 'Explorar',
      simulation = 'Simulado',
      profile = 'Profile',
      socialSoon = 'Em breve, conquistas e desafios com amigos.',
      socialNews = 'Novidades',
      socialRanking = 'Ranking',
      socialFriends = 'Amigos',
      socialLikes = 'Curtidas',
      socialLoadError = 'Não foi possível carregar as novidades.',
      socialEmpty = 'Quando seus amigos estudarem, as novidades aparecem aqui.',
      socialFindFriends = 'Encontrar amigos',
      socialRequiresAccount =
          'Social, Amigos e Ranking ficam disponíveis depois que você salvar seu progresso com uma conta.',
      exploreHint = 'Busque uma matéria ou conteúdo',
      exploreSearchHint = 'O que você quer aprender?',
      exploreRecentSearches = 'Buscas recentes',
      exploreContinueLearning = 'Continuar estudando',
      exploreBySubject = 'Explore por matéria',
      exploreClearHistory = 'Limpar',
      exploreEmptyTitle = 'Não encontramos esse conteúdo.',
      exploreEmptySubtitle = 'Tente buscar de outro jeito.',
      exploreFilterSubject = 'Matéria',
      exploreFilterYear = 'Ano',
      exploreFilterAll = 'Todas',
      exploreFilterAllYears = 'Todos',
      start = 'Começar',
      temporaryAccount = 'Conta temporária',
      selectToReview = 'Selecionar para revisar',
      startActivity = 'Começar atividade',
      checkAnswer = 'Verificar',
      finish = 'Concluir',
      correctFeedback = 'Muito bem!',
      almostFeedback = 'Quase.',
      continueLabel = 'Continuar',
      correctTitle = 'Correto!',
      incorrectTitle = 'Incorreto!',
      correctAnswer = 'Resposta correta',
      answerExplanation = 'Entenda por quê',
      noXpOutsideJourney = 'Este modo é para estudar e não concede XP.',
      selectAtLeastOne = 'Selecione pelo menos um conteúdo.',
      startSimulation = 'Começar simulado',
      simulationIntro = 'Monte um treino do seu jeito e acompanhe seu desempenho.',
      simulationContinueSaved = 'Continuar simulado',
      simulationSelectSubjects = 'Escolha uma ou mais matérias',
      simulationContents = 'Conteúdos',
      simulationSelectContents = 'Escolha o que quer treinar',
      simulationQuestions = 'Questões',
      simulationTime = 'Tempo',
      simulationTightTime = 'Essa quantidade de questões nesse tempo pode ficar apertada.',
      simulationAllContents = 'Todos os conteúdos selecionados',
      simulationExit = 'Sair',
      simulationExitTitle = 'Sair do simulado?',
      simulationExitDescription = 'Seu progresso deste simulado será encerrado.',
      simulationContinue = 'Continuar',
      simulationOpenQuestionPanel = 'Abrir painel de questões',
      simulationFinishTitle = 'Finalizar simulado?',
      simulationFinishDescription = 'Suas respostas serão corrigidas agora.',
      simulationFinishAnyway = 'Finalizar mesmo assim',
      simulationReview = 'Revisar',
      simulationReviewLater = 'Revisar depois',
      simulationMarkedForReview = 'Marcada para revisão',
      simulationResult = 'Resultado',
      simulationTimeEnded = 'O tempo terminou. Suas respostas foram salvas.',
      simulationCorrect = 'acertos',
      simulationIncorrect = 'erros',
      simulationBlank = 'em branco',
      simulationUsedTime = 'tempo utilizado',
      simulationBySubject = 'Por matéria',
      simulationByContent = 'Por conteúdo',
      simulationReviewAnswers = 'Revisar respostas',
      simulationAnother = 'Fazer outro simulado',
      simulationExcellent = 'Excelente resultado.',
      simulationWellDone = 'Mandou bem.',
      simulationAlmostThere = 'Quase lá.',
      simulationNotAnswered = 'Não respondida',
      simulationYourAnswer = 'Sua resposta',
      previous = 'Anterior',
      next = 'Próxima',
      skip = 'Pular',
      emptyResults = 'Nenhum conteúdo encontrado.',
      contentUnavailable = 'Esta atividade ainda não está disponível offline. Verifique sua conexão e tente novamente.',
      loadingContent = 'Carregando conteúdo',
      lessonLoadingTitle = "A chama do conhecimento\nestá acesa.",
      lessonCampfireIllustration = 'Ilustração de uma chama acesa sobre dois troncos.',
      closeActivity = 'Fechar atividade',
      back = 'Voltar',
      reportError = 'Reportar erro',
      reportProblemTitle = 'Reporte um problema',
      reportProblemDescription = 'Selecione as opções que melhor descrevem o problema encontrado:',
      reportOptionAudioIncorrect = 'O áudio parece incorreto',
      reportOptionAudioMissing = 'Falta áudio no texto',
      reportOptionWritingError = 'Conteúdo com erro de escrita.',
      reportOptionLogicError = 'Conteúdo com erro de lógica.',
      reportOptionWrongAnswer = 'Resposta da atividade está errada.',
      reportOptionOtherError = 'Outro erro.',
      reportDetailsHint = 'Ex.: Tem um erro de ortografia...',
      cancel = 'Cancelar',
      send = 'Enviar',
      reportSentSuccess = 'Relato enviado com sucesso. Obrigado!',
      reportSentFailure = 'Não foi possível enviar o relato no momento.',
      lessonContent = 'Conteúdo',
      activitiesSummary = 'Resumo das atividades',
      activityResult = 'Resultado da atividade',
      activityReviewSuggestion = 'Vale revisar este conteúdo mais uma vez.',
      backToHome = 'Voltar para Home',
      activitiesSummaryIntro = 'Veja como você se saiu nas atividades desta aula.',
      activityNotDone = 'Não feito',
      activityCorrect = 'Correta',
      activityIncorrect = 'Incorreta',
      tryAgain = 'Tentar novamente',
      playLessonAudio = 'Ouvir conteúdo da aula',
      pauseLessonAudio = 'Pausar leitura da aula',
      completeAllLessons = 'Complete todas as aulas',
      answeredActivity = 'Atividade respondida',
      currentActivity = 'Atividade atual',
      essayHint = 'Escreva...',
      trueLabel = 'Verdadeiro',
      falseLabel = 'Falso',
      xpLabel = 'Pontos de experiência',
      levelLabel = 'Nível atual',
      stageElementarySchoolShort = 'EF',
      stageHighSchoolShort = 'EM',
      lessonCompletedSemantics = 'concluído',
      lessonZeroPercentSemantics = '0 por cento',
      indicatorAnsweredCorrect = 'respondida corretamente',
      indicatorAnsweredIncorrect = 'respondida incorretamente',
      indicatorContent = 'conteúdo',
      indicatorUnanswered = 'ainda não respondida',
      indicatorSummary = 'resumo disponível',
      indicatorSummaryDisabled = 'resumo com atividades pendentes',
      multipleChoiceActivityName = 'Escolha uma resposta',
      textInputActivityName = 'Complete a resposta',
      essayActivityName = 'Palavra',
      fillBlankActivityName = 'Complete os espaços',
      orderingActivityName = 'Organize as palavras',
      sequencingActivityName = 'Organize a sequência',
      matchingActivityName = 'Faça as associações',
      memoryActivityName = 'Jogo da memória',
      trueFalseActivityName = 'Verdadeiro ou falso',
      imageChoiceActivityName = 'Escolha uma imagem',
      wordCompletionActivityName = 'Complete a palavra',
      subjectPortuguese = 'Português',
      subjectEnglish = 'Inglês',
      subjectSpanish = 'Espanhol',
      subjectMathematics = 'Matemática',
      subjectScience = 'Ciências',
      subjectBiology = 'Biologia',
      subjectPhysics = 'Física',
      subjectChemistry = 'Química',
      subjectHistory = 'História',
      subjectGeography = 'Geografia',
      subjectPhilosophy = 'Filosofia',
      subjectSociology = 'Sociologia';

  static String lessonPage(int current, int total, String label) =>
      '$current de $total - $label';
  static String openSection(String label) => 'Abrir $label';
  static String selectedContents(int count) =>
      count == 1 ? '1 conteúdo selecionado' : '$count conteúdos selecionados';
  static String simulationConfirmation(
    int questions,
    String subjects,
    int minutes,
  ) => '$questions questões\n$subjects\n$minutes minutos';
  static String remainingTime(String value) => 'Tempo restante: $value';
  static String unansweredWarning(int count) => count == 1
      ? 'Você deixou 1 questão em branco.'
      : 'Você deixou $count questões em branco.';
  static String questionState(
    int number,
    bool answered,
    bool marked,
    bool current,
  ) =>
      'Questão $number, ${current ? 'atual, ' : ''}${answered ? 'respondida' : 'não respondida'}${marked ? ', marcada para revisão' : ''}';
  static String simulationStrength(String content) =>
      'Você mandou melhor em $content.';
  static String simulationImprove(String content) => 'Vale revisar $content.';
  static String xpValue(int value) => '$value XP';
  static String levelValue(int value) => 'Você está no nível $value.';
  static String schoolYear(int year) => '$yearº ano';
  static String level(int value) => 'Nível $value';
  static String completedLessons(int value) =>
      value == 1 ? '1 lição concluída' : '$value lições concluídas';
  static String recommendationReason(String lesson) =>
      'Reforce $lesson e avance com confiança.';
  static String correctAnswerValue(String answer) => '$correctAnswer\n$answer';
  static String activitiesSummaryResult(int correct, int total) =>
      'Você acertou $correct de $total atividades.';
  static String activityDuration(int minutes) =>
      'Você terminou em $minutes min.';
  static String activityEarnedXp(int value) => 'Você ganhou $value XP.';
  static String essayCounter(int length, int maxLength) => '$length/$maxLength';
  static String memoryPairs(int found, int total) => '$found/$total';
  static String percent(num value) => '$value%';
  static String highSchoolSeries(int year) => '$year EM';
  static String stageElementarySchoolYear(int year) => '$yearº ano EF';
  static String stageHighSchoolYear(int year) => '$yearª série EM';
  static String progressRatio(int current, int total) => '$current/$total';
  static String lessonSemantics(String title, bool isCompleted) =>
      '$title, ${isCompleted ? lessonCompletedSemantics : lessonZeroPercentSemantics}';
  static String pageIndicatorSemantics(int current, int total, String state) =>
      'Página $current de $total, $state';
  static String activityItemSemantics(int position, String status) =>
      'Atividade $position, $status';
  static String activityItemSummary(int position, String status) =>
      'Atividade $position · $status';

  static String activityName(QuestionType type) => switch (type) {
    QuestionType.multipleChoice => multipleChoiceActivityName,
    QuestionType.textInput => textInputActivityName,
    QuestionType.essay => essayActivityName,
    QuestionType.fillBlank => fillBlankActivityName,
    QuestionType.ordering => orderingActivityName,
    QuestionType.sequencing => sequencingActivityName,
    QuestionType.matching => matchingActivityName,
    QuestionType.memory => memoryActivityName,
    QuestionType.trueFalse => trueFalseActivityName,
    QuestionType.imageChoice => imageChoiceActivityName,
    QuestionType.wordCompletion => wordCompletionActivityName,
  };

  static String subjectName(SubjectType subject) => switch (subject) {
    SubjectType.portuguese => subjectPortuguese,
    SubjectType.english => subjectEnglish,
    SubjectType.spanish => subjectSpanish,
    SubjectType.mathematics => subjectMathematics,
    SubjectType.science => subjectScience,
    SubjectType.biology => subjectBiology,
    SubjectType.physics => subjectPhysics,
    SubjectType.chemistry => subjectChemistry,
    SubjectType.history => subjectHistory,
    SubjectType.geography => subjectGeography,
    SubjectType.philosophy => subjectPhilosophy,
    SubjectType.sociology => subjectSociology,
  };
}
