class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.schoolYear,
    required this.isTemporary,
  });
  final String id;
  final String displayName;
  final int schoolYear;
  final bool isTemporary;
  Map<String, dynamic> toMap() => {
    'id': id,
    'displayName': displayName,
    'schoolYear': schoolYear,
    'isTemporary': isTemporary,
  };
  factory AppUser.fromMap(Map<dynamic, dynamic> map) => AppUser(
    id: map['id'] as String,
    displayName: map['displayName'] as String,
    schoolYear: map['schoolYear'] as int,
    isTemporary: map['isTemporary'] as bool,
  );
}
