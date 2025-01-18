import 'package:feederr/models/article_category.dart';
import 'package:feederr/models/category.dart';
import 'package:feederr/models/feed_category.dart';
import 'package:feederr/models/categoryentry.dart';
import 'package:feederr/models/feedentry.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/models/article.dart';
import 'package:feederr/models/unread.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/tag.dart';
import 'package:feederr/models/feed.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, 'feederrdb.db');

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  // When the database is first created, create a table to store articles
  // and a table to store UnreadIds.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE server_list(id INTEGER PRIMARY KEY AUTOINCREMENT, baseUrl TEXT, userName TEXT, password TEXT, auth TEXT)',
    );
    await db.execute(
      'CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
    );
    await db.execute(
      'CREATE TABLE feed_list(id2 INTEGER PRIMARY KEY AUTOINCREMENT, id TEXT, title TEXT, categories TEXT, url TEXT, htmlUrl TEXT, iconUrl TEXT, count INTEGER, serverId INTEGER, FOREIGN KEY (serverId) REFERENCES server_list(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE articles(id TEXT, id2 INTEGER PRIMARY KEY AUTOINCREMENT, crawlTimeMsec TEXT, timestampUsec TEXT, published int, title TEXT, canonical TEXT, alternate TEXT, categories TEXT, origin_streamId TEXT, origin_htmlUrl TEXT, origin_title TEXT, summary_content TEXT, author TEXT, imageUrl TEXT, serverId INTEGER, feedId INTEGER, FOREIGN KEY (serverId) REFERENCES server_list(id) ON DELETE CASCADE, FOREIGN KEY (feedId) REFERENCES feed_list(id2) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE articles_categories (article_id INTEGER, category_id INTEGER, PRIMARY KEY (article_id, category_id), FOREIGN KEY (article_id) REFERENCES articles(id2) ON DELETE CASCADE, FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE feed_categories (feed_id INTEGER, category_id INTEGER, PRIMARY KEY (feed_id, category_id), FOREIGN KEY (feed_id) REFERENCES feed_list(id2) ON DELETE CASCADE, FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE starred_ids(articleId INTEGER PRIMARY KEY AUTOINCREMENT, serverId INTEGER, FOREIGN KEY (serverId) REFERENCES server_list(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE unread_ids(articleId INTEGER PRIMARY KEY AUTOINCREMENT, serverId INTEGER, FOREIGN KEY (serverId) REFERENCES server_list(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE tag_list(id2 INTEGER PRIMARY KEY AUTOINCREMENT, id TEXT, type TEXT, count INTEGER, serverId INTEGER, FOREIGN KEY (serverId) REFERENCES server_list(id) ON DELETE CASCADE)',
    );
    // await db.execute(
    //   'CREATE TABLE tagged_ids(articleId INTEGER PRIMARY KEY, serverId INTEGER, tag INTEGER, FOREIGN KEY (serverId) REFERENCES server_list(id) ON DELETE CASCADE)',
    // );
  }

  // Define a function that inserts articles into the database
  Future<int> insertArticle(Article article) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Insert the Article into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same article is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'articles',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return article.id2 ?? 0;
  }

  Future<void> insertUnreadId(UnreadId id) async {
    final db = await _databaseService.database;
    await db.insert('unread_ids', id.toMap());
  }

  Future<void> insertStarredId(StarredId id) async {
    final db = await _databaseService.database;
    await db.insert('starred_ids', id.toMap());
  }

  // Future<void> insertTaggedId(TaggedId id) async {
  //   final db = await _databaseService.database;
  //   await db.insert('tagged_ids', id.toMap());
  // }

  Future<void> insertTag(Tag tag) async {
    final db = await _databaseService.database;
    await db.insert('tag_list', tag.toMap());
  }

  Future<int> insertFeed(Feed feed) async {
    final db = await _databaseService.database;
    return await db.insert('feed_list', feed.toMap());
  }

  Future<void> insertServer(Server server) async {
    final db = await _databaseService.database;
    await db.insert(
      'server_list',
      server.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the articles from the articles table.
  Future<List<Article>> articles() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the articles.
    final List<Map<String, dynamic>> maps = await db.query('articles');

    // Convert the List<Map<String, dynamic> into a List<Article>.
    return List.generate(
        maps.length, (index) => Article.fromDBMap(maps[index]));
  }

  Future<StarredId?> starredId(int? articleId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db
        .query('starred_ids', where: 'articleId = ?', whereArgs: [articleId]);
    if (maps.isNotEmpty) {
      return StarredId.fromDBMap(maps[0]);
    } else {
      return null;
    }
  }
  // Future<List<Article>> allArticlesByTag(String tag) async {
  //   final db = await _databaseService.database;
  //   final List<Map<String, dynamic>> articles = await db.rawQuery('''
  //   SELECT articles.*
  //   FROM articles
  //   INNER JOIN tagged_ids ON articles.id2 = tagged_ids.articleId
  //   WHERE tagged_ids.tag = ?
  // ''', [tag]);
  //   return List.generate(
  //       articles.length, (index) => Article.fromDBMap(articles[index]));
  // }

  // Future<List<Article>> starredArticlesByTag(String tag) async {
  //   final db = await _databaseService.database;
  //   final List<Map<String, dynamic>> articles = await db.rawQuery('''
  //   SELECT articles.*
  //   FROM articles
  //   INNER JOIN tagged_ids ON articles.id2 = tagged_ids.articleId
  // INNER JOIN starred_ids ON articles.id2 = starred_ids.articleId
  //   WHERE tagged_ids.tag = ?
  // ''', [tag]);
  //   return List.generate(
  //       articles.length, (index) => Article.fromDBMap(articles[index]));
  // }

  // Future<List<Article>> unreadArticlesByTag(String tag) async {
  //   final db = await _databaseService.database;
  //   final List<Map<String, dynamic>> articles = await db.rawQuery('''
  //   SELECT articles.*
  //   FROM articles
  //   INNER JOIN tagged_ids ON articles.id2 = tagged_ids.articleId
  //   INNER JOIN unread_ids ON articles.id2 = unread_ids.articleId
  //   WHERE tagged_ids.tag = ?
  // ''', [tag]);
  //   return List.generate(
  //       articles.length, (index) => Article.fromDBMap(articles[index]));
  // }

  Future<Article?> article(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('articles', where: 'id2 = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Article.fromDBMap(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<UnreadId>> unreadIds() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('unread_ids');
    return List.generate(
        maps.length, (index) => UnreadId.fromDBMap(maps[index]));
  }

  Future<List<StarredId>> starredIds() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('starred_ids');
    return List.generate(
        maps.length, (index) => StarredId.fromDBMap(maps[index]));
  }

  // Future<List<TaggedId>> taggedIds() async {
  //   final db = await _databaseService.database;
  //   final List<Map<String, dynamic>> maps = await db.query('tagged_ids');
  //   return List.generate(
  //       maps.length, (index) => TaggedId.fromDBMap(maps[index]));
  // }

  // Future<List<TaggedId>> taggedIdsByTag(String tag) async {
  //   final db = await _databaseService.database;
  //   final List<Map<String, dynamic>> maps =
  //       await db.query('tagged_ids', where: 'tag = ?', whereArgs: [tag]);
  //   return List.generate(
  //       maps.length, (index) => TaggedId.fromDBMap(maps[index]));
  // }

  Future<List<Tag>> tags() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('tag_list');
    return List.generate(maps.length, (index) => Tag.fromMap(maps[index]));
  }

  Future<Tag> tag(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('tag_list', where: 'id = ?', whereArgs: [id]);
    return Tag.fromMap(maps[0]);
  }

  Future<List<Feed>> feeds() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('feed_list');
    return List.generate(maps.length, (index) => Feed.fromDBMap(maps[index]));
  }

  Future<List<Feed>> feedsByServerId(int serverId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db
        .query('feed_list', where: 'serverId = ?', whereArgs: [serverId]);
    return List.generate(maps.length, (index) => Feed.fromDBMap(maps[index]));
  }

  Future<Feed?> feedByServerAndFeedId(int serverId, String feedId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('feed_list',
        where: 'serverId = ? AND id = ?', whereArgs: [serverId, feedId]);
    if (maps.isEmpty) {
      return null; // Or handle the case where no Feed is found
    } else {
      return Feed.fromDBMap(maps[0]);
    }
  }

  Future<Feed> feed(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('feed_list', where: 'id = ?', whereArgs: [id]);
    return Feed.fromDBMap(maps[0]);
  }

  Future<Feed> feedById2(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('feed_list', where: 'id2 = ?', whereArgs: [id]);
    return Feed.fromDBMap(maps[0]);
  }

  Future<List<Server>> servers() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('server_list');
    return List.generate(maps.length, (index) => Server.fromMap(maps[index]));
  }

  Future<Server> server(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('server_list', where: 'id = ?', whereArgs: [id]);
    return Server.fromMap(maps[0]);
  }

  Future<Server?> serverByUrlAndUsername(
      String baseUrl, String userName) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query('server_list',
        where: 'baseUrl = ? AND userName = ?', whereArgs: [baseUrl, userName]);
    if (maps.isNotEmpty) {
      return Server.fromMap(maps[0]);
    } else {
      return null;
    }
  }

  // A method that updates a article data from the articles table.
  Future<void> updateArticle(Article article) async {
    final db = await _databaseService.database;

    await db.update(
      'articles',
      article.toMap(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  // A method that updates a tags data from the taglist table.
  Future<void> updateTag(Tag tag) async {
    final db = await _databaseService.database;

    await db.update(
      'tag_list',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  // A method that updates a feeds data from the feedlist table.
  Future<void> updateFeed(Feed feed) async {
    final db = await _databaseService.database;

    await db.update(
      'feed_list',
      feed.toMap(),
      where: 'id = ?',
      whereArgs: [feed.id],
    );
  }

  // A method that updates a feeds data from the feedlist table.
  Future<void> updateServer(Server server) async {
    final db = await _databaseService.database;

    await db.update(
      'server_list',
      server.toMap(),
      where: 'id = ?',
      whereArgs: [server.id],
    );
  }

  // A method that deletes a article data from the articles table.
  Future<void> deleteArticle(int id) async {
    final db = await _databaseService.database;

    await db.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUnreadId(int id) async {
    final db = await _databaseService.database;
    await db.delete('unread_ids', where: 'articleId = ?', whereArgs: [id]);
  }

  Future<void> deleteStarredId(int id) async {
    final db = await _databaseService.database;
    await db.delete('starred_ids', where: 'articleId = ?', whereArgs: [id]);
  }

  Future<void> deleteTag(String id) async {
    final db = await _databaseService.database;
    await db.delete('tag_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteFeed(String id) async {
    final db = await _databaseService.database;
    await db.delete('feed_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTaggedId(int id) async {
    final db = await _databaseService.database;
    await db.delete('feed_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteServer(int id) async {
    final db = await _databaseService.database;
    await db.delete('server_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteServerByUrlAndUser(String baseUrl, String userName) async {
    final db = await _databaseService.database;
    await db.delete('server_list',
        where: 'baseUrl = ? AND userName = ?', whereArgs: [baseUrl, userName]);
  }

  Future<int> insertCategory(Category category) async {
    final db = await _databaseService.database;
    int id = await db.insert('categories', category.toMap());
    return id;
  }

  Future<void> insertArticleWithCategories(
      Article article, List<String> categories) async {
    // Insert article first to get the article ID
    int articleId = await insertArticle(article);

    // Insert categories if they don't exist
    await Future.forEach(categories, (category) async {
      if (category.contains('user/-/label')) {
        int categoryId = await getCategoryOrCreate(category);

        ArticleCategory? aC = await getArticleCategory(articleId, categoryId);
        if (aC == null) {
          ArticleCategory artCat =
              ArticleCategory(articleId: articleId, categoryId: categoryId);
          await insertArticleCategory(artCat);
        }
      }
    });
  }

  Future<void> insertFeedWithCategories(
      Feed feed, List<String> categories) async {
    int feedId;
    // Insert article first to get the article ID
    Feed? f = await feedByServerAndFeedId(feed.serverId, feed.id);
    if (f == null) {
      feedId = await insertFeed(feed);
    } else {
      feedId = f.id2 ?? 0;
    }

    // Insert categories if they don't exist
    await Future.forEach(categories, (category) async {
      int categoryId = await getCategoryOrCreate(category);

      FeedCategory? fC = await getFeedCategory(feedId, categoryId);
      if (fC == null) {
        FeedCategory feedCat =
            FeedCategory(feedId: feedId, categoryId: categoryId);
        await insertFeedCategory(feedCat);
      }
    });
  }

  Future<int> getCategoryOrCreate(String category) async {
    final db = await _databaseService.database;
    category = category.split('/').last;
    final List<Map<String, dynamic>> maps =
        await db.query('categories', where: 'name = ?', whereArgs: [category]);
    if (maps.isNotEmpty) {
      Category c = Category.fromMap(maps[0]);
      return c.id!;
    } else {
      // return await insertCategory(Category(name: category));
      int id = await db.insert(
        'categories',
        Category(name: category).toMap(),
      );
      return id;
    }
  }

  Future<List<Category>> categories() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (index) => Category.fromMap(maps[index]));
  }

  Future<void> insertArticleCategory(ArticleCategory articleCategory) async {
    final db = await _databaseService.database;
    await db.insert('articles_categories', articleCategory.toMap());
  }

  Future<ArticleCategory?> getArticleCategory(
      int articleId, int categoryId) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
        'articles_categories',
        where: 'article_id = ? AND category_id = ?',
        whereArgs: [articleId, categoryId]);
    if (maps.isEmpty) {
      return null; // Or handle the case where no Feed is found
    } else {
      return ArticleCategory.fromMap(maps[0]);
    }
  }

  Future<List<ArticleCategory>> articlesCategory() async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps =
        await db.query('articles_categories');

    return List.generate(
        maps.length, (index) => ArticleCategory.fromMap(maps[index]));
  }

  Future<void> insertFeedCategory(FeedCategory feedCategory) async {
    final db = await _databaseService.database;
    await db.insert('feed_categories', feedCategory.toMap());
  }

  Future<FeedCategory?> getFeedCategory(int feedId, int categoryId) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query('feed_categories',
        where: 'feed_id = ? AND category_id = ?',
        whereArgs: [feedId, categoryId]);

    if (maps.isEmpty) {
      return null; // Or handle the case where no Feed is found
    } else {
      return FeedCategory.fromMap(maps[0]);
    }
  }

  Future<List<FeedCategory>> feedCategory() async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query('feed_categories');

    return List.generate(
        maps.length, (index) => FeedCategory.fromMap(maps[index]));
  }

  Future<List<CategoryEntry>> getCategoryEntries() async {
    final db = await _databaseService.database;
    // Get all categories
    // Get all categories
    final categoryMaps = await db.query('categories');
    final categories =
        categoryMaps.map((map) => Category.fromMap(map)).toList();

    // For each category, get the feeds and articles
    List<CategoryEntry> categoryEntries = [];
    for (var category in categories) {
      // Get feeds for the category
      final feedMaps = await db.rawQuery('''
      SELECT feed_list.* FROM feed_list
      JOIN feed_categories ON feed_list.id2 = feed_categories.feed_id
      WHERE feed_categories.category_id = ?
    ''', [category.id]);
      final feeds = feedMaps.map((map) => Feed.fromMap(map)).toList();

      // For each feed, get the articles
      List<FeedEntry> feedEntries = [];
      for (var feed in feeds) {
        final feedArticleMaps = await db.rawQuery('''
        SELECT articles.* FROM articles
        WHERE articles.origin_streamId = ?
      ''', [feed.id]);
        final feedArticles =
            feedArticleMaps.map((map) => Article.fromDBMap(map)).toList();

        feedEntries.add(FeedEntry(
            feed: feed, articles: feedArticles, count: feedArticles.length));
      }

      // Get articles for the category
      final articleMaps = await db.rawQuery('''
      SELECT articles.* FROM articles
      JOIN articles_categories ON articles.id2 = articles_categories.article_id
      WHERE articles_categories.category_id = ?
    ''', [category.id]);
      final articles =
          articleMaps.map((map) => Article.fromDBMap(map)).toList();

      List<UnreadId>? liUnreadIds = await unreadIds();
      List<StarredId>? liStarredIds = await starredIds();
      for (Article article in articles) {
        article.isStarred = true;
        article.isRead = false;

        if (liUnreadIds
            .where((element) => element.articleId == article.id2)
            .isNotEmpty) {
          article.isRead = false;
        } else {
          article.isRead = true;
        }
        if (liStarredIds
            .where((element) => element.articleId == article.id2)
            .isNotEmpty) {
          article.isStarred = true;
        } else {
          article.isStarred = false;
        }
      }
      // Create the CategoryEntry
      categoryEntries.add(CategoryEntry(
          category: category,
          feedEntry: feedEntries,
          articles: articles,
          count: articles.length));
    }

    return categoryEntries;
  }

  Future<List<CategoryEntry>> getCategoryEntriesWithStarredArticles() async {
    final db = await _databaseService.database;
    // Get all categories
    final categoryMaps = await db.query('categories');
    final categories =
        categoryMaps.map((map) => Category.fromMap(map)).toList();

    // For each category, get the feeds and articles
    List<CategoryEntry> categoryEntries = [];
    for (var category in categories) {
      // Get feeds for the category
      final feedMaps = await db.rawQuery('''
      SELECT feed_list.* FROM feed_list
      JOIN feed_categories ON feed_list.id2 = feed_categories.feed_id
      WHERE feed_categories.category_id = ?
    ''', [category.id]);
      final feeds = feedMaps.map((map) => Feed.fromMap(map)).toList();

      // For each feed, get the articles
      List<FeedEntry> feedEntries = [];
      for (var feed in feeds) {
        final feedArticleMaps = await db.rawQuery('''
        SELECT articles.* FROM articles
        JOIN starred_ids ON articles.id2 = starred_ids.articleId
        WHERE articles.origin_streamId = ?
      ''', [feed.id]);
        List<Article> feedArticles =
            feedArticleMaps.map((map) => Article.fromDBMap(map)).toList();

        if (feedArticles.isNotEmpty) {
          feedEntries.add(FeedEntry(
              feed: feed, articles: feedArticles, count: feedArticles.length));
        }
      }

      // Get articles for the category
      final articleMaps = await db.rawQuery('''
      SELECT articles.* FROM articles
      JOIN articles_categories ON articles.id2 = articles_categories.article_id
      JOIN starred_ids ON articles.id2 = starred_ids.articleId
      WHERE articles_categories.category_id = ?
    ''', [category.id]);
      final articles =
          articleMaps.map((map) => Article.fromDBMap(map)).toList();

      List<UnreadId>? liUnreadIds = await unreadIds();
      for (Article article in articles) {
        article.isStarred = true;
        article.isRead = false;

        if (liUnreadIds
            .where((element) => element.articleId == article.id2)
            .isNotEmpty) {
          article.isRead = false;
        } else {
          article.isRead = true;
        }
      }
      // Create the CategoryEntry
      if (feedEntries.isNotEmpty) {
        categoryEntries.add(CategoryEntry(
            category: category,
            feedEntry: feedEntries,
            articles: articles,
            count: articles.length));
      }
    }

    return categoryEntries;
  }

  Future<List<CategoryEntry>> getCategoryEntriesWithNewArticles() async {
    final db = await _databaseService.database;
    // Get all categories
    final categoryMaps = await db.query('categories');
    final categories =
        categoryMaps.map((map) => Category.fromMap(map)).toList();

    // For each category, get the feeds and articles
    List<CategoryEntry> categoryEntries = [];
    for (var category in categories) {
      // Get feeds for the category
      final feedMaps = await db.rawQuery('''
      SELECT feed_list.* FROM feed_list
      JOIN feed_categories ON feed_list.id2 = feed_categories.feed_id
      WHERE feed_categories.category_id = ?
    ''', [category.id]);
      final feeds = feedMaps.map((map) => Feed.fromMap(map)).toList();

      // For each feed, get the articles
      List<FeedEntry> feedEntries = [];
      for (var feed in feeds) {
        final feedArticleMaps = await db.rawQuery('''
        SELECT articles.* FROM articles
        JOIN unread_ids ON articles.id2 = unread_ids.articleId
        WHERE articles.origin_streamId = ?
      ''', [feed.id]);
        final feedArticles =
            feedArticleMaps.map((map) => Article.fromDBMap(map)).toList();

        if (feedArticles.isNotEmpty) {
          feedEntries.add(FeedEntry(
              feed: feed, articles: feedArticles, count: feedArticles.length));
        }
      }

      // Get articles for the category
      final articleMaps = await db.rawQuery('''
      SELECT articles.* FROM articles
      JOIN articles_categories ON articles.id2 = articles_categories.article_id
      JOIN unread_ids ON articles.id2 = unread_ids.articleId
      WHERE articles_categories.category_id = ?
    ''', [category.id]);
      final articles =
          articleMaps.map((map) => Article.fromDBMap(map)).toList();

      // List<UnreadId> liUnreadId = await unreadIds();
      List<StarredId>? liStarredIds = await starredIds();
      for (Article article in articles) {
        article.isRead = false;
        // StarredId starred = ;
        if (liStarredIds
            .where((element) => element.articleId == article.id2)
            .isNotEmpty) {
          article.isStarred = true;
        } else {
          article.isStarred = false;
        }
      }
      // Create the CategoryEntry
      if (feedEntries.isNotEmpty) {
        categoryEntries.add(CategoryEntry(
            category: category,
            feedEntry: feedEntries,
            articles: articles,
            count: articles.length));
      }
    }

    return categoryEntries;
  }
}
