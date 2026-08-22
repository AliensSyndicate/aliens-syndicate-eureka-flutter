import '../enums/social_event_type.dart';
import '../models/model_social_event.dart';

class SocialTemplateService {
  const SocialTemplateService();
  String titleFor(SocialEvent event) {
    final topic = event.metadata['topic'] ?? 'um novo conteúdo';
    final score = event.metadata['score'];
    final badge = event.metadata['badge'] ?? 'um novo selo';
    final xp = event.metadata['xp'];
    final position = event.metadata['position'];
    final streak = event.metadata['streak'];
    return switch (event.type) {
      SocialEventType.activityCompleted => 'Terminou $topic!',
      SocialEventType.topicCompleted => 'Dominou o tópico $topic!',
      SocialEventType.highScore => 'Mandou muito bem em $topic: $score%!',
      SocialEventType.scoreImproved => 'Melhorou sua nota em $topic!',
      SocialEventType.badgeUnlocked => 'Conquistou $badge em $topic!',
      SocialEventType.rankingPromotion ||
      SocialEventType.rankingPositionImproved =>
        'Subiu para a $positionª posição do ranking!',
      SocialEventType.studyStreak =>
        'Completou $streak dias estudando no Eureka!',
      SocialEventType.xpMilestone => 'Chegou a $xp XP!',
      SocialEventType.simulationCompleted => 'Terminou o simulado com $score%!',
      SocialEventType.perfectActivity => 'Acertou tudo em $topic!',
    };
  }
}
