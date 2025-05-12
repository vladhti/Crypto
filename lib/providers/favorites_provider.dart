import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    notifyListeners();
  }

  Future<void> toggleFavorite(String assetId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorites.contains(assetId)) {
      _favorites.remove(assetId);
    } else {
      _favorites.add(assetId);
    }
    await prefs.setStringList('favorites', _favorites.toList());
    notifyListeners();
  }

  bool isFavorite(String assetId) => _favorites.contains(assetId);
}
