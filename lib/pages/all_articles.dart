import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:feederr/models/feed.dart';
import 'package:flutter/material.dart';

class AllArticleList extends StatelessWidget {
  const AllArticleList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("All articles");
  }
}

Future<List<Feed>> fetchAllFeeds() async {
  try {
    var headers = {
      'Authorization':
          'GoogleLogin auth=nikhil/afe65a20b5bb1a9b76bf8d32a82f4dccd22b819a'
    };
    var dio = Dio();
    var response = await dio.request(
      'https://rss.nikpatil.com/api/greader.php/reader/api/0/subscription/list?output=json',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
      return response.data;
    } else {
      print(response.statusMessage);
    }
  } on DioException catch (e) {
    if (e.response != null) {
      print(e.response?.data);
      print(e.response?.headers);
      print(e.response?.requestOptions);
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print(e.requestOptions);
      print(e.message);
    }
  }
  return [];
}
