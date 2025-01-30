import 'package:feederr/models/local_feeds/local_feedentry.dart';
import 'package:flutter/material.dart';

class LocalFeedsProvider extends ChangeNotifier {
  List<LocalFeedEntry> _feeds;

  LocalFeedsProvider._internal(this._feeds);

  List<LocalFeedEntry> get feeds => _feeds;
  bool get isEmpty => _feeds.isEmpty;
  bool get isNotEmpty => _feeds.isNotEmpty;
  int get length => _feeds.length;

  static Future<LocalFeedsProvider> create(List<LocalFeedEntry> feedEntries) async {
    return LocalFeedsProvider._internal(feedEntries);
  }

  static LocalFeedsProvider createEmpty() {
    return LocalFeedsProvider._internal([]);
  }

  Future<void> initiateCategories() async {
    _feeds = <LocalFeedEntry>[];
    notifyListeners(); // Notify listeners when settings are loaded
  }

  Future<void> updateCategories(List<LocalFeedEntry> feedEntries) async {
    _feeds = feedEntries;
    notifyListeners();
  }
}
