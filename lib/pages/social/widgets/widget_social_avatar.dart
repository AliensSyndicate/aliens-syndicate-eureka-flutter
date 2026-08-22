import 'package:flutter/material.dart';
import '../../../models/social/model_user_preview.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';

class SocialAvatar extends StatelessWidget {
  const SocialAvatar({
    required this.user,
    this.size = UiSize.avatarMd,
    super.key,
  });
  final UserPreview user;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Avatar de ${user.displayName}',
    image: true,
    child: ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: user.avatarColor,
          border: Border.all(color: UiColor.outline),
        ),
        alignment: Alignment.center,
        child: UiIcon.user(size: size * .62, color: UiColor.background),
      ),
    ),
  );
}
