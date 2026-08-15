class ActivityReference {
  const ActivityReference({
    required this.id,
    required this.version,
    this.checksum,
    this.order = 0,
  });
  final String id;
  final int version;
  final String? checksum;
  final int order;

  factory ActivityReference.fromMap(Map<String, dynamic> map) =>
      ActivityReference(
        id: map['id'] as String,
        version: map['version'] as int,
        checksum: map['checksum'] as String?,
        order: map['order'] as int? ?? 0,
      );
  Map<String, dynamic> toMap() => {
    'id': id,
    'version': version,
    'checksum': checksum,
    'order': order,
  };
}
