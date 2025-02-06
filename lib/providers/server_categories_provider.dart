import 'package:blazefeeds/models/categories/categoryentry.dart';
import 'package:flutter/material.dart';

class ServerCatogoriesProvider extends ChangeNotifier {
  List<CategoryEntry> _categoryEntries;

  ServerCatogoriesProvider._internal(this._categoryEntries);

  List<CategoryEntry> get categoryEntries => _categoryEntries;
  bool get isEmpty => _categoryEntries.isEmpty;
  bool get isNotEmpty => _categoryEntries.isNotEmpty;
  int get length => _categoryEntries.length;

  static Future<ServerCatogoriesProvider> create(List<CategoryEntry> categoryEntries) async {
    return ServerCatogoriesProvider._internal(categoryEntries);
  }

  static ServerCatogoriesProvider createEmpty() {
    return ServerCatogoriesProvider._internal([]);
  }

  Future<void> initiateCategories() async {
    _categoryEntries = <CategoryEntry>[];
    notifyListeners(); // Notify listeners when settings are loaded
  }

  Future<void> updateCategories(List<CategoryEntry> categoryEntry) async {
    _categoryEntries = categoryEntry;
    notifyListeners();
  }
}
