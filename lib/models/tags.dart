import 'dart:convert';

class Tag {
  final String id;
  final String type;
  final int count;

  Tag({
    required this.id,
    required this.type,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'count': count,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      count: map['count'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) => Tag.fromMap(json.decode(source));

  @override
  String toString() => 'Tag(id: $id, type:$type, count:$count)';
}
