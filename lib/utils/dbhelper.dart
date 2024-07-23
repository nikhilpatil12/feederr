import 'package:feederr/models/servers.dart';
import 'package:feederr/models/articles.dart';
import 'package:feederr/models/new.dart';
import 'package:feederr/models/starred.dart';
import 'package:feederr/models/tags.dart';
import 'package:feederr/models/feed_list.dart';
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
    final path = join(databasePath, 'feederr.db');

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
  // and a table to store NewIds.
  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {all_articles} TABLE statement on the database.
    // 'CREATE TABLE all_articles(id INTEGER PRIMARY KEY, title TEXT, article TEXT)',
    await db.execute(
        'CREATE TABLE articles(id INTEGER, id2 TEXT, crawlTimeMsec TEXT, timestampUsec TEXT, published TEXT, title TEXT, canonical TEXT, alternate TEXT, categories TEXT, origin_streamId TEXT, origin_htmlUrl TEXT, origin_title TEXT, summary_content TEXT, author TEXT');
    // Run the CREATE {starred} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE starred_ids(FOREIGN KEY (articleId) REFERENCES all_articles(id) ON DELETE SET NULL)',
    );
    await db.execute(
      'CREATE TABLE new_ids(FOREIGN KEY (articleId) REFERENCES all_articles(id) ON DELETE SET NULL)',
    );
    await db.execute(
      'CREATE TABLE tag_list(id TEXT PRIMARY KEY, type TEXT, count INTEGER)',
    );
    await db.execute(
      'CREATE TABLE feed_list(id TEXT PRIMARY KEY, title TEXT, categories TEXT, url TEXT, htmlUrl TEXT, iconUrl TEXT',
    );
    await db.execute(
      'CREATE TABLE server_list(id INTEGER PRIMARY KEY, baseUrl TEXT, userName TEXT, password TEXT, auth TEXT',
    );
  }

  // Define a function that inserts articles into the database
  Future<void> insertArticle(Article article) async {
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
  }

  Future<void> insertNewId(NewId id) async {
    final db = await _databaseService.database;
    await db.insert(
      'new_ids',
      id.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStarredId(StarredId id) async {
    final db = await _databaseService.database;
    await db.insert(
      'starred_ids',
      id.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTag(Tag tag) async {
    final db = await _databaseService.database;
    await db.insert(
      'tag_list',
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFeed(Feed feed) async {
    final db = await _databaseService.database;
    await db.insert(
      'feed_list',
      feed.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    return List.generate(maps.length, (index) => Article.fromMap(maps[index]));
  }

  Future<Article> article(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('articles', where: 'id = ?', whereArgs: [id]);
    return Article.fromMap(maps[0]);
  }

  Future<List<NewId>> newIds() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('new_ids');
    return List.generate(maps.length, (index) => NewId.fromMap(maps[index]));
  }

  Future<List<StarredId>> starredIds() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('starred_ids');
    return List.generate(
        maps.length, (index) => StarredId.fromMap(maps[index]));
  }

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
    return List.generate(maps.length, (index) => Feed.fromMap(maps[index]));
  }

  Future<Feed> feed(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('feed_list', where: 'id = ?', whereArgs: [id]);
    return Feed.fromMap(maps[0]);
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

  Future<void> deleteNewId(int id) async {
    final db = await _databaseService.database;
    await db.delete('new_ids', where: 'articleId = ?', whereArgs: [id]);
  }

  Future<void> deleteStarredId(int id) async {
    final db = await _databaseService.database;
    await db.delete('starred_ids', where: 'articleId = ?', whereArgs: [id]);
  }

  Future<void> deleteTag(int id) async {
    final db = await _databaseService.database;
    await db.delete('tag_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteFeed(int id) async {
    final db = await _databaseService.database;
    await db.delete('feed_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteServer(int id) async {
    final db = await _databaseService.database;
    await db.delete('server_list', where: 'id = ?', whereArgs: [id]);
  }
}
