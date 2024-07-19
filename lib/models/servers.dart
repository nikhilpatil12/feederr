import 'dart:convert';

class Server {
  final int? id;
  final String baseUrl;
  final String userName;
  final String password;

  Server({
    this.id,
    required this.baseUrl,
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baseUrl': baseUrl,
      'userName': userName,
      'password': password,
    };
  }

  factory Server.fromMap(Map<String, dynamic> map) {
    return Server(
      id: map['id']?.toInt() ?? 0,
      baseUrl: map['baseUrl'] ?? '',
      userName: map['userName'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Server.fromJson(String source) => Server.fromMap(json.decode(source));

  @override
  String toString() =>
      'Server(id:$id, baseUrl: $baseUrl, userName:$userName, password:$password)';
}
