import 'package:flutter/material.dart';

class UserPreview {
  const UserPreview({
    required this.id,
    required this.displayName,
    required this.avatarColor,
    this.schoolYear = 5,
    this.xp = 0,
  });
  final String id;
  final String displayName;
  final Color avatarColor;
  final int schoolYear;
  final int xp;
}
