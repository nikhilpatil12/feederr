import 'dart:convert';

class Tag {
  final String id;
  final int? id2;
  final String type;
  final int count;
  int serverId;

  Tag({
    required this.id,
    this.id2,
    required this.type,
    required this.count,
    required this.serverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // 'id2': id2,
      'type': type,
      'count': count,
      'serverId': serverId,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] ?? '',
      id2: map['id2'] ?? 0,
      type: map['type'] ?? '',
      count: map['count'] ?? 0,
      serverId: map['serverId'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) => Tag.fromMap(json.decode(source));

  @override
  String toString() =>
      'Tag(id: $id, type:$type, count:$count, serverId:$serverId)';
}
