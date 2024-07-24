import 'package:dio/dio.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/widgets/article.dart';
import 'package:flutter/material.dart';
import 'package:feederr/utils/utils.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

  @override
  ArticleListState createState() => ArticleListState();
}

class ArticleListState extends State<ArticleList> {
  List<Article> articles = [];
  bool isLoading = false;
  DatabaseService databaseService = DatabaseService();

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
      // articles = await fetchArticles();
      // for (Article article in articles) {
      //   DatabaseService databaseService = DatabaseService();
      //   databaseService.insertArticle(article);
      // }
      articles = await databaseService.articles();
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
                  article: article,
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
