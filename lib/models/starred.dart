import 'dart:convert';

class StarredId {
  final int articleId;
  int serverId;

  StarredId({
    required this.articleId,
    required this.serverId,
  });

  // Convert a StarredId into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
      'serverId': serverId,
    };
  }

  factory StarredId.fromMap(Map<String, dynamic> map) {
    return StarredId(
      articleId: int.parse(map['id'] ?? '0'),
      serverId: map['serverId'] ?? 0,
    );
  }
  factory StarredId.fromDBMap(Map<String, dynamic> map) {
    return StarredId(
      articleId: map['articleId'] ?? 0,
      serverId: map['serverId'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StarredId.fromJson(String source) =>
      StarredId.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each starred_id when using the print statement.
  @override
  String toString() => 'StarredId(articleId: $articleId serverId:$serverId)';
}
