import 'package:dio/dio.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/widgets/article.dart';
import 'package:flutter/cupertino.dart';

class ArticleList extends StatefulWidget {
  final VoidCallback refreshParent;
  final List<Article> articles;
  const ArticleList({
    super.key,
    required this.refreshParent,
    required this.articles,
  });

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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            widget.refreshParent();
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) =>
                ArticleListItem(article: widget.articles[index]),
            childCount: widget.articles.length,
          ),
        ),
      ],
    );
  }
}
