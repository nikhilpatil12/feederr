import 'dart:convert';

class StarredId {
  final String articleId;

  StarredId({
    required this.articleId,
  });

  // Convert a StarredId into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
    };
  }

  factory StarredId.fromMap(Map<String, dynamic> map) {
    return StarredId(
      articleId: map['articleId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StarredId.fromJson(String source) =>
      StarredId.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each starred_id when using the print statement.
  @override
  String toString() => 'StarredId(articleId: $articleId)';
}
