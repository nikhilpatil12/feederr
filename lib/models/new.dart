import 'dart:convert';

class NewId {
  final String articleId;

  NewId({
    required this.articleId,
  });

  // Convert a NewId into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
    };
  }

  factory NewId.fromMap(Map<String, dynamic> map) {
    return NewId(
      articleId: map['articleId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NewId.fromJson(String source) => NewId.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each new_id when using the print statement.
  @override
  String toString() => 'NewId(articleId: $articleId)';
}
