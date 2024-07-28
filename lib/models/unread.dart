import 'dart:convert';

class UnreadId {
  final int articleId;
  int serverId;

  UnreadId({
    required this.articleId,
    required this.serverId,
  });

  // Convert a NewId into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
      'serverId': serverId,
    };
  }

  factory UnreadId.fromMap(Map<String, dynamic> map) {
    return UnreadId(
      articleId: int.parse(map['id'] ?? '0'),
      serverId: map['serverId'] ?? 0,
    );
  }
  factory UnreadId.fromDBMap(Map<String, dynamic> map) {
    return UnreadId(
      articleId: map['articleId'] ?? 0,
      serverId: map['serverId'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UnreadId.fromJson(String source) =>
      UnreadId.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each new_id when using the print statement.
  @override
  String toString() => 'NewId(articleId: $articleId, serverId:$serverId)';
}
