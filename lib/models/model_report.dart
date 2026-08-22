class ReportModel {
  const ReportModel({
    required this.id,
    required this.userId,
    required this.reasons,
    this.details,
    this.lessonId,
    this.lessonTitle,
    this.questionId,
    this.questionPrompt,
    this.subjectId,
    this.pageNumber,
    required this.createdAt,
    this.status = 'pending',
  });

  final String id;
  final String userId;
  final List<String> reasons;
  final String? details;
  final String? lessonId;
  final String? lessonTitle;
  final String? questionId;
  final String? questionPrompt;
  final String? subjectId;
  final int? pageNumber;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'reasons': reasons,
    'details': details,
    'lessonId': lessonId,
    'lessonTitle': lessonTitle,
    'questionId': questionId,
    'questionPrompt': questionPrompt,
    'subjectId': subjectId,
    'pageNumber': pageNumber,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'status': status,
  };

  factory ReportModel.fromMap(Map<String, dynamic> map) => ReportModel(
    id: map['id'] as String? ?? '',
    userId: map['userId'] as String? ?? '',
    reasons:
        (map['reasons'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    details: map['details'] as String?,
    lessonId: map['lessonId'] as String?,
    lessonTitle: map['lessonTitle'] as String?,
    questionId: map['questionId'] as String?,
    questionPrompt: map['questionPrompt'] as String?,
    subjectId: map['subjectId'] as String?,
    pageNumber: map['pageNumber'] as int?,
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    status: map['status'] as String? ?? 'pending',
  );
}
