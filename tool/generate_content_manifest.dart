import 'dart:convert';
import 'dart:io';

import 'package:eureka/data/seed/seed_content_manifest.dart';

/// Gera o documento publicável a partir da mesma matriz usada offline.
void main() {
  final manifest = buildSeedContentManifest();
  final document = {
    'published': true,
    'schemaVersion': manifest.schemaVersion,
    'contentVersion': manifest.contentVersion,
    'payload': manifest.toMap(),
  };
  const encoder = JsonEncoder.withIndent('  ');
  File(
    'firebase/content/content_manifest.json',
  ).writeAsStringSync('${encoder.convert(document)}\n');
}
