import 'dart:convert';

class ArticleCategory {
  final int articleId;
  final int categoryId;

  ArticleCategory({
    required this.articleId,
    required this.categoryId,
  });

  // Convert a Category into a Map. The keys must correspond to the categoryIds of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'article_id': articleId,
      'category_id': categoryId,
    };
  }

  factory ArticleCategory.fromMap(Map<String, dynamic> map) {
    return ArticleCategory(
      articleId: int.parse(map['article_id'] ?? '0'),
      categoryId: map['category_id'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ArticleCategory.fromJson(String source) =>
      ArticleCategory.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each new_articleId when using the print statement.
  @override
  String toString() =>
      'ArticleCategory(articleId: $articleId, categoryId:$categoryId)';
}
