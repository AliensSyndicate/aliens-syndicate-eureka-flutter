import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/repository_report.dart';
import '../models/model_report.dart';

class FirestoreReportRepository implements ReportRepository {
  FirestoreReportRepository(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<void> submitReport(ReportModel report) async {
    final docRef = report.id.isNotEmpty
        ? _firestore.collection('reports').doc(report.id)
        : _firestore.collection('reports').doc();

    final data = {
      ...report.toMap(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'clientCreatedAt': report.createdAt.toUtc().toIso8601String(),
    };

    await docRef.set(data);
  }
}
