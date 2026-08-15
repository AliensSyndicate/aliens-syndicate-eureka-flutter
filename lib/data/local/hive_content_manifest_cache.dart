import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/content/model_content_manifest.dart';

class HiveContentManifestCache {
  HiveContentManifestCache(this._box);
  final Box<dynamic> _box;
  static const _manifestKey = 'content_manifest_json';
  static const _versionKey = 'content_manifest_version';

  int? get version => _box.get(_versionKey) as int?;
  ContentManifest? read() {
    final json = _box.get(_manifestKey) as String?;
    if (json == null) return null;
    try {
      return ContentManifest.fromMap(
        Map<String, dynamic>.from(jsonDecode(json) as Map),
      );
    } on Object {
      return null;
    }
  }

  Future<void> write(ContentManifest manifest) => _box.putAll({
    _versionKey: manifest.contentVersion,
    _manifestKey: jsonEncode(manifest.toMap()),
  });
}
