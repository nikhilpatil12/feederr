import 'package:dio/dio.dart';
import 'package:feederr/models/articles.dart';
import 'package:feederr/utils/db_utils.dart';
import 'package:flutter/material.dart';
import 'package:feederr/utils/utils.dart';

class ArticleListItem extends StatelessWidget {
  const ArticleListItem({
    super.key,
    required this.title,
    required this.timeStamp,
    required this.origin,
    required this.imageUrl,
  });

  final String title;
  final String timeStamp;
  final String origin;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: _ArticleDetails(
              title: title,
              timeStamp: timeStamp,
              origin: origin,
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.network(imageUrl),
          ),
        ],
      ),
    );
  }
}

class _ArticleDetails extends StatelessWidget {
  const _ArticleDetails(
      {required this.title, required this.timeStamp, required this.origin});

  final String title;
  final String timeStamp;
  final String origin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            origin,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color.fromRGBO(76, 2, 232, 1),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            timeStamp,
            style: const TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  List<Article> articles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      isLoading = true;
    });
    try {
      articles = await FetchArticles();
    } on DioException catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleListItem(
                  title: article.title,
                  imageUrl: article.imageUrl,
                  origin: article.originTitle + " (" + article.author + ")",
                  timeStamp: timeAgo(article.published),
                );
                // ListTile(
                //   title: Text(article.title),
                //   subtitle: Text(article.author),
                // );
              },
            ),
    );
  }
}
