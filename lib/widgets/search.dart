import 'dart:async';
import 'dart:ui';

import 'package:blazefeeds/models/article.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/widgets/article.dart';
import 'package:flutter/material.dart';

class Debouncer {
  final Duration duration;
  Timer? _timer;
  int _currentVersion = 0;

  Debouncer({int milliseconds = 300}) : duration = Duration(milliseconds: milliseconds);

  void run(VoidCallback action) {
    _timer?.cancel();
    final version = ++_currentVersion;

    _timer = Timer(duration, () {
      if (!_timer!.isActive && version == _currentVersion) {
        action();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _currentVersion = 0;
  }
}

class ArticleSearchDelegate extends SearchDelegate<String> {
  final List<Article> articles;
  final Debouncer _debouncer;
  final APIService api;
  final DatabaseService databaseService;
  List<Article>? _cachedResults;
  String? _lastQuery;

  // Pre-compile regex patterns for better performance
  final RegExp _whitespaceRegex = RegExp(r'\s+');

  ArticleSearchDelegate({required this.articles, required this.api, required this.databaseService})
      : _debouncer = Debouncer(milliseconds: 300);

  @override
  void close(BuildContext context, String result) {
    _debouncer.dispose();
    super.close(context, result);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _cachedResults = [];
            if (context.mounted) showSuggestions(context);
          },
        ),
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    // Cache theme values to avoid repeated lookups
    final secondaryColor = theme.colorScheme.secondary;
    final onSurfaceVariantColor = theme.colorScheme.onSurfaceVariant;

    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: secondaryColor,
        prefixIconColor: onSurfaceVariantColor,
        suffixIconColor: onSurfaceVariantColor,
        hintStyle: TextStyle(
          color: onSurfaceVariantColor,
          fontSize: 16,
        ),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  List<Article> _filterAndSortArticles(String queryText) {
    // Return early if query is empty or cached results exist
    if (queryText.isEmpty) return [];
    if (queryText == _lastQuery && _cachedResults != null) {
      return _cachedResults!;
    }

    // Normalize query text by removing extra whitespace
    final queryLower = queryText.trim().toLowerCase().replaceAll(_whitespaceRegex, ' ');

    // Use Set for faster lookups during filtering
    final Set<Article> results = {};

    // Implement efficient filtering
    for (final article in articles) {
      if (article.title.toLowerCase().contains(queryLower) ||
          article.summaryContent.toLowerCase().contains(queryLower) ||
          article.alternate.toLowerCase().contains(queryLower) ||
          article.author.toLowerCase().contains(queryLower)) {
        results.add(article);
      }
    }

    // Convert to list and sort
    final sortedResults = results.toList()
      ..sort((a, b) {
        // Optimize sorting by reducing string operations
        final aTitleMatch = a.title.toLowerCase().contains(queryLower);
        final bTitleMatch = b.title.toLowerCase().contains(queryLower);

        if (aTitleMatch != bTitleMatch) return aTitleMatch ? -1 : 1;
        return b.published.compareTo(a.published);
      });

    _lastQuery = queryText;
    _cachedResults = sortedResults;
    return sortedResults;
  }

  @override
  Widget buildResults(BuildContext context) => _buildArticleList(_filterAndSortArticles(query));

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      _cachedResults = [];
      return const SizedBox.shrink();
    }

    _debouncer.run(() {
      if (!context.mounted) return;
      final suggestions = _filterAndSortArticles(query);
      if (_cachedResults != suggestions) {
        _cachedResults = suggestions;
        showSuggestions(context);
      }
    });

    return _cachedResults == null
        ? const Center(child: CircularProgressIndicator())
        : _buildArticleList(_cachedResults!);
  }

  Widget _buildArticleList(List<Article> items) {
    return ListView.builder(
      itemCount: items.length,
      // Add cacheExtent to improve scrolling performance
      cacheExtent: 100,
      itemBuilder: (context, index) => ArticleListItem(
        articles: items,
        articleIndex: index,
        api: api,
        databaseService: databaseService,
        onReturn: (_) {},
      ),
    );
  }
}
