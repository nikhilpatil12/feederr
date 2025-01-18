import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/feed.dart';
import 'package:feederr/models/tagged_id.dart';
import 'package:feederr/models/unread.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/tag.dart';

class APIService {
  final Dio _dio;

  APIService() : _dio = Dio();

  Future<String> userLogin(
      String baseUrl, String userName, String password) async {
    try {
      final encodedUsername = Uri.encodeComponent(userName);
      final encodedPassword = Uri.encodeComponent(password);
      var response = await _dio.request(
        '$baseUrl/api/greader.php/accounts/ClientLogin?Email=$encodedUsername&Passwd=$encodedPassword',
        options: Options(
          method: 'GET',
        ),
      );

      if (response.statusCode == 200) {
        // print(json.encode(response.data));
        List<String> lines = response.data.split('\n');
        Map<String, String> values = {};
        for (String line in lines) {
          if (line.isNotEmpty) {
            List<String> parts = line.split('=');
            if (parts.length == 2) {
              values[parts[0]] = parts[1];
            }
          }
        }
        String? auth = values['Auth'];
        return auth ?? '404';
      } else {
        return '404';
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return '404';
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return '404';
      }
    } catch (e) {
      // Handle other errors
      // print('Request failed with error: $e');
      return '404';
    }
  }

  Future<List<Feed>?> fetchFeedList(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/subscription/list?output=json',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // print(json.encode(response.data));
        final data = response.data["subscriptions"] as List;
        return data.map((feed) => Feed.fromMap(feed)).toList();
      } else {
        // print(response.statusMessage);
        return null;
      }
    } on DioException catch (dioException) {
      // Handle Dio specific errors
      if (dioException.response != null) {
        throw Exception(
            'DioError: ${dioException.response?.statusCode} - ${dioException.response?.statusMessage}');
      } else {
        throw Exception('DioError: ${dioException.message}');
      }
    } catch (e) {
      // Handle other errors
      // print('Request failed with error: $e');
      print(e);
      return null;
    }
  }

  Future<List<Tag>?> fetchTagList(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/tag/list?output=json',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // print(json.encode(response.data));
        final data = response.data["tags"] as List;
        return data.map((tag) => Tag.fromMap(tag)).toList();
      } else {
        // print(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return null;
    }
  }

  Future<List<UnreadId>?> fetchUnreadIds(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/stream/items/ids?s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&n=10000&output=json',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // print(json.encode(response.data));

        Map<String, dynamic> resp = jsonDecode(response.data);
        final data = resp["itemRefs"] as List;
        return data.map((id) => UnreadId.fromMap(id)).toList();
      } else {
        // print(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return null;
    }
  }

  Future<List<StarredId>?> fetchStarredIds(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/stream/items/ids?output=json&n=10000&s=user/-/state/com.google/starred',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // print(json.encode(response.data));

        Map<String, dynamic> resp = jsonDecode(response.data);
        final data = resp["itemRefs"] as List;
        return data.map((id) => StarredId.fromMap(id)).toList();
      } else {
        // print(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return null;
    }
  }

  Future<List<TaggedId>?> fetchTaggedIds(
      String baseUrl, String auth, String tag) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/stream/items/ids?output=json&n=10000&s=$tag',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // print(json.encode(response.data));

        Map<String, dynamic> resp = jsonDecode(response.data);
        final data = resp["itemRefs"] as List;
        return data.map((id) => TaggedId.fromMap(id)).toList();
      } else {
        // print(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return null;
    }
  }

  Future<List<Article>?> fetchNewArticleContents(
      String baseUrl, String auth, var data) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/stream/items/contents',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        // print(json.encode(response.data));

        final data = response.data["items"] as List;
        return data.map((article) => Article.fromMap(article)).toList();
      } else {
        // print(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return null;
    }
  }

  Future<String> markAsRead(String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'a': 'user/-/state/com.google/read'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print("OK");

        return "OK";
      } else {
        print(response.statusMessage);
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return "Error";
    }
  }

  Future<String> markAsUnread(
      String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'r': 'user/-/state/com.google/read'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print("OK");

        return "OK";
      } else {
        print(response.statusMessage);
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return "Error";
    }
  }

  Future<String> markAsStarred(
      String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'a': 'user/-/state/com.google/starred'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print("OK");
        print(response.statusMessage);

        return "OK";
      } else {
        print(response.statusMessage);
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return "Error";
    }
  }

  Future<String> markAsNotStarred(
      String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'r': 'user/-/state/com.google/starred'};
      var response = await _dio.request(
        '$baseUrl/api/greader.php/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print("OK");

        return "OK";
      } else {
        print(response.statusMessage);
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // print('DioError response: ${dioExcpetion.response?.data}');
        // print('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // print('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      print('Request failed with error: $e');
      return "Error";
    }
  }
}
