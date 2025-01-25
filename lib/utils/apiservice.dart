import 'dart:convert';
import 'dart:developer';

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
      // final encodedUsername = Uri.encodeComponent(userName);
      // final encodedPassword = Uri.encodeComponent(password);
      var response = await _dio.request(
        '$baseUrl/accounts/ClientLogin',
        options: Options(
          method: 'POST',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {'Email': userName, 'Passwd': password},
      );

      if (response.statusCode == 200) {
        // log(json.encode(response.data));
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
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return '404';
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return '404';
      }
    } catch (e) {
      // Handle other errors
      // log('Request failed with error: $e');
      return '404';
    }
  }

  Future<List<Feed>?> fetchFeedList(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/subscription/list?output=json',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // log(json.encode(response.data));
        final data = response.data["subscriptions"] as List;
        return data.map((feed) => Feed.fromMap(feed)).toList();
      } else {
        // log(response.statusMessage);
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
      log('Request failed with error 1: $e');
      // log(e);
      return null;
    }
  }

  Future<List<Tag>?> fetchTagList(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/tag/list?output=json',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // log(json.encode(response.data));
        final data = response.data["tags"] as List;
        return data.map((tag) => Tag.fromMap(tag)).toList();
      } else {
        // log(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 2: $e');
      return null;
    }
  }

  Future<List<UnreadId>?> fetchUnreadIds(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/stream/items/ids?s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&n=10000&output=json',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      Map<String, dynamic> resp;
      if (response.statusCode == 200) {
        // log(json.encode(response.data));
        // Map<String, dynamic> resp = response.data;
        // Map<String, dynamic> resp = jsonDecode(response.data);
        if (response.data is Map<String, dynamic>) {
          // Already a Map, no need to decode
          resp = response.data;
        } else if (response.data is String) {
          // If it's a JSON string, decode it
          resp = jsonDecode(response.data);
        } else {
          // Handle unexpected data type
          throw Exception("Unexpected response data format");
        }
        final data = resp["itemRefs"] as List;
        return data.map((id) => UnreadId.fromMap(id)).toList();
      } else {
        // log(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 3: $e');
      return null;
    }
  }

  Future<List<StarredId>?> fetchStarredIds(String baseUrl, String auth) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/stream/items/ids?output=json&n=10000&s=user/-/state/com.google/starred',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      Map<String, dynamic> resp;
      if (response.statusCode == 200) {
        // log(json.encode(response.data));

        // Map<String, dynamic> resp = jsonDecode(response.data);
        // Map<String, dynamic> resp = response.data;
        if (response.data is Map<String, dynamic>) {
          // Already a Map, no need to decode
          resp = response.data;
        } else if (response.data is String) {
          // If it's a JSON string, decode it
          resp = jsonDecode(response.data);
        } else {
          // Handle unexpected data type
          throw Exception("Unexpected response data format");
        }
        final data = resp["itemRefs"] as List;
        return data.map((id) => StarredId.fromMap(id)).toList();
      } else {
        // log(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 4: $e');
      return null;
    }
  }

  Future<List<TaggedId>?> fetchTaggedIds(
      String baseUrl, String auth, String tag) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/stream/items/ids?output=json&n=10000&s=$tag',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // log(json.encode(response.data));

        Map<String, dynamic> resp = jsonDecode(response.data);
        final data = resp["itemRefs"] as List;
        return data.map((id) => TaggedId.fromMap(id)).toList();
      } else {
        // log(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 5: $e');
      return null;
    }
  }

  Future<List<Article>?> fetchNewArticleContents(
      String baseUrl, String auth, List<String> itemIds) async {
    try {
      var headers = {
        'Authorization': 'GoogleLogin auth=$auth',
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      String data = itemIds.map((id) => 'i=$id').join('&');
      data += '&T=$auth&output=json&n=1000';
      var response = await _dio.request(
        '$baseUrl/reader/api/0/stream/items/contents',
        options: Options(
          method: 'POST',
          headers: headers,
          // contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        // log(json.encode(response.data));

        final data = response.data["items"] as List;
        return data.map((article) => Article.fromMap(article)).toList();
      } else {
        // log(response.statusMessage);
        return null;
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        log('DioError response: ${dioExcpetion.response?.data}');
        log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return null;
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return null;
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 6: $e');
      return null;
    }
  }

  Future<String> markAsRead(String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'a': 'user/-/state/com.google/read'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        log("OK");

        return "OK";
      } else {
        log("Error: $response.statusMessage");
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 7: $e');
      return "Error";
    }
  }

  Future<String> markAsUnread(
      String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'r': 'user/-/state/com.google/read'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        log("OK");

        return "OK";
      } else {
        log("Error: $response.statusMessage");
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 8: $e');
      return "Error";
    }
  }

  Future<String> markAsStarred(
      String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'a': 'user/-/state/com.google/starred'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        log("OK");

        return "OK";
      } else {
        log("Error: $response.statusMessage");
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 9: $e');
      return "Error";
    }
  }

  Future<String> markAsNotStarred(
      String baseUrl, String? auth, int articleId) async {
    try {
      var headers = {'Authorization': 'GoogleLogin auth=$auth'};
      var data = {'i': articleId, 'r': 'user/-/state/com.google/starred'};
      var response = await _dio.request(
        '$baseUrl/reader/api/0/edit-tag',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        log("OK");

        return "OK";
      } else {
        log("Error: $response.statusMessage");
        return "Error";
      }
    } on DioException catch (dioExcpetion) {
      // Handle Dio specific errors
      if (dioExcpetion.response != null) {
        // log('DioError response: ${dioExcpetion.response?.data}');
        // log('DioError status code: ${dioExcpetion.response?.statusCode}');
        return "Error";
      } else {
        // Something happened in setting up the request that triggered an Error
        // log('DioError message: ${dioExcpetion.message}');
        return "Error";
      }
    } catch (e) {
      // Handle other errors
      log('Request failed with error 10: $e');
      return "Error";
    }
  }

  Future<dynamic> fetchLocalFeedContents(String baseUrl) async {
    var response = await _dio.request(
      baseUrl,
      options: Options(
        method: 'GET',
      ),
    );
    if (response.statusCode == 200) {
      log("Fetch feed: OK");

      return response;
    } else {
      log("Fetch feed Error: $response.statusMessage");
      return "Error";
    }
  }

  Future<String> getArticleSummary(Article article, String apikey) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apikey',
      // 'Cookie':
      //     '__cf_bm=JJtyNVsB8_ADyr1hZTkWtYXed3v7rSIfc1qNnMZKy2c-1737679757-1.0.1.1-4mq3fB..MoxxqmPsDqH84X_GPTdBr1kT0rYKUax.Uag.cjd0DhBnHGCl.0.ROj0v8LDrCTRcXjEsRTgw9eO3sw; _cfuvid=EwoBXtQ8rMggnLsrUjpzt14MoGnB_NtYCObaVCEoqVk-1737678677232-0.0.1.1-604800000'
    };
    var data = json.encode({
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "developer",
          "content":
              "You will be provided with a RSS article, along with it's title. Summarize the article in plain text."
        },
        {
          "role": "user",
          "content":
              "Title: ${article.title} Content: ${article.summaryContent}"
        }
      ]
    });
    var dio = Dio();
    var response = await dio.request(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print("OK");
      print(json.encode(response.data));
      return json.encode(response.data);
    } else {
      print(response.statusMessage);
      return "";
    }
  }
}
