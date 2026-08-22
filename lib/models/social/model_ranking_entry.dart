import 'model_user_preview.dart';

class RankingEntry {
  const RankingEntry({
    required this.position,
    required this.user,
    required this.isCurrentUser,
  });
  final int position;
  final UserPreview user;
  final bool isCurrentUser;
}
