import 'dart:convert';

class Category {
  final int? id;
  String name;

  Category({
    this.id,
    required this.name,
  });

  // Convert a Category into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each new_id when using the print statement.
  @override
  String toString() => 'Category(id: $id, name:$name)';
}
