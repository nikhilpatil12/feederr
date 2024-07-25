import 'dart:convert';

class FeedCategory {
  final String feedId;
  final int categoryId;

  FeedCategory({
    required this.feedId,
    required this.categoryId,
  });

  // Convert a Category into a Map. The keys must correspond to the categoryIds of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'feed_id': feedId,
      'category_id': categoryId,
    };
  }

  factory FeedCategory.fromMap(Map<String, dynamic> map) {
    return FeedCategory(
      feedId: map['feed_id'] ?? '',
      categoryId: map['category_id'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedCategory.fromJson(String source) =>
      FeedCategory.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each new_feedId when using the print statement.
  @override
  String toString() => 'FeedCategory(feedId: $feedId, categoryId:$categoryId)';
}
