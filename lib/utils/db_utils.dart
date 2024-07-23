import 'package:dio/dio.dart';
import 'package:feederr/models/articles.dart';

Future<List<Article>> FetchArticles() async {
  var headers = {
    'Authorization':
        'GoogleLogin auth=nikhil/afe65a20b5bb1a9b76bf8d32a82f4dccd22b819a'
  };
  var dio = Dio();
  var response = await dio.request(
    'http://debian:8020/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/reading-list?n=10',
    options: Options(
      method: 'GET',
      headers: headers,
    ),
  );
  final data = response.data["items"] as List;
  return data.map((article) => Article.fromMap(article)).toList();
}
