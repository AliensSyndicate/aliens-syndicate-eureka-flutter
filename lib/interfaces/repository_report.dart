import '../models/model_report.dart';

abstract interface class ReportRepository {
  Future<void> submitReport(ReportModel report);
}
