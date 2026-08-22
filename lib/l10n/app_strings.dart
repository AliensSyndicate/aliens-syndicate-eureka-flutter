import '../enums/question_type.dart';
import '../enums/subject_type.dart';

abstract final class AppStrings {
  static const appName = 'Eureka',
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
      startActivity = 'Começar atividade',
      checkAnswer = 'Verificar',
      finish = 'Concluir',
      correctFeedback = 'Muito bem!',
      correctTitle = 'Correto!',
      incorrectTitle = 'Incorreto!',
      correctAnswer = 'Resposta correta',
      answerExplanation = 'Entenda por quê',
      noXpOutsideJourney = 'Este modo é para estudar e não concede XP.',
      selectAtLeastOne = 'Selecione pelo menos um conteúdo.',
      startSimulation = 'Começar simulado',
      emptyResults = 'Nenhum conteúdo encontrado.',
      contentUnavailable =
          'Esta atividade ainda não está disponível offline. Verifique sua conexão e tente novamente.',
      loadingContent = 'Carregando conteúdo',
      lessonLoadingTitle = "A chama do conhecimento\nestá acesa.",
      lessonCampfireIllustration =
          'Ilustração de uma chama acesa sobre dois troncos.',
      closeActivity = 'Fechar atividade',
      back = 'Voltar',
      reportError = 'Reportar erro',
      reportErrorUnavailable = 'O envio de relatos estará disponível em breve.',
      lessonContent = 'Conteúdo',
      activitiesSummary = 'Resumo das atividades',
      activitiesSummaryIntro =
          'Veja como você se saiu nas atividades desta aula.',
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
      createEurekaAccount = 'Criar conta Eureka',
      createEurekaAccountDescription =
          'Salve seu progresso na nuvem, acesse de outros dispositivos e mantenha seus dados seguros.',
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
