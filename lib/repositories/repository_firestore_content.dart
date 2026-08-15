import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/repository_content.dart';
import '../models/content/model_content_manifest.dart';
import '../models/model_lesson.dart';

class FirestoreContentRepository implements ContentRepository {
  FirestoreContentRepository(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<ContentManifest?> fetchManifest() async {
    final document = await _firestore
        .collection('content_manifests')
        .doc('current')
        .get();
    final data = document.data();
    if (data == null || data['published'] != true || data['enabled'] != true) {
      return null;
    }
    return ContentManifest.fromMap(
      Map<String, dynamic>.from(data['payload'] as Map),
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchActivity(String activityId) async {
    final document = await _firestore
        .collection('content_activities')
        .doc(activityId)
        .get();
    final data = document.data();
    if (data == null || data['published'] != true || data['enabled'] != true) {
      return null;
    }
    return Map<String, dynamic>.from(data['payload'] as Map);
  }

  @override
  Future<List<Lesson>> findPublishedLessons({required int schoolYear}) async =>
      (await fetchManifest())?.lessonsForYear(schoolYear) ?? const [];
}
