import '../interfaces/repository_report.dart';
import '../models/model_report.dart';
import 'service_user.dart';

class ReportService {
  ReportService({
    required ReportRepository? repository,
    required UserService userService,
  }) : _repository = repository,
       _userService = userService;

  final ReportRepository? _repository;
  final UserService _userService;

  Future<bool> sendReport({
    required List<String> reasons,
    String? details,
    String? lessonId,
    String? lessonTitle,
    String? questionId,
    String? questionPrompt,
    String? subjectId,
    int? pageNumber,
  }) async {
    final cleanDetails = details?.trim();
    if (reasons.isEmpty && (cleanDetails == null || cleanDetails.isEmpty)) {
      return false;
    }

    final user = _userService.loadCurrentUser();
    final report = ReportModel(
      id: '${DateTime.now().millisecondsSinceEpoch}_${user.id}',
      userId: user.id,
      reasons: List.unmodifiable(reasons),
      details: cleanDetails?.isEmpty == true ? null : cleanDetails,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      questionId: questionId,
      questionPrompt: questionPrompt,
      subjectId: subjectId,
      pageNumber: pageNumber,
      createdAt: DateTime.now(),
      status: 'pending',
    );

    if (_repository == null) {
      // Quando offline ou sem Firebase configurado, aceita localmente sem erro.
      return true;
    }

    try {
      await _repository.submitReport(report);
      return true;
    } catch (_) {
      return false;
    }
  }
}
