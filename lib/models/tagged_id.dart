import 'dart:convert';

class TaggedId {
  final int articleId;
  int serverId;
  String tag;

  TaggedId({
    required this.articleId,
    required this.serverId,
    required this.tag,
  });

  // Convert a Id into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {'articleId': articleId, 'serverId': serverId, 'tag': tag};
  }

  factory TaggedId.fromMap(Map<String, dynamic> map) {
    return TaggedId(
      articleId: int.parse(map['id'] ?? '0'),
      serverId: map['serverId'] ?? 0,
      tag: map['tag'] ?? '',
    );
  }
  factory TaggedId.fromDBMap(Map<String, dynamic> map) {
    return TaggedId(
      articleId: map['articleId'] ?? 0,
      serverId: map['serverId'] ?? 0,
      tag: map['tag'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaggedId.fromJson(String source) =>
      TaggedId.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each new_id when using the print statement.
  @override
  String toString() =>
      'Id(articleId: $articleId, serverId:$serverId), tag:$tag';
}
