import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/article.dart';
import '../services/api_service.dart';

class NewsProvider with ChangeNotifier {
  List<Article> _articles = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = '';
  String _searchQuery = '';

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;

  final ApiService _apiService = ApiService();

  NewsProvider() {
    fetchNews();
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _articles = await _getCachedArticles();
      } else {
        _articles = await _apiService.fetchNews(
          category: _selectedCategory,
          query: _searchQuery,
        );
        await _cacheArticles(_articles);
      }
    } catch (e) {
      _error = e.toString();
      _articles = await _getCachedArticles();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category.toLowerCase();
    _searchQuery = '';
    fetchNews();
  }

  void search(String query) {
    _searchQuery = query;
    _selectedCategory = '';
    fetchNews();
  }

  Future<void> _cacheArticles(List<Article> articles) async {
    var box = await Hive.openBox('articles');
    await box.put('cached_articles', articles.map((e) => e.toJson()).toList());
  }

  Future<List<Article>> _getCachedArticles() async {
    var box = await Hive.openBox('articles');
    List<dynamic> cached = box.get('cached_articles', defaultValue: []);
    return cached.map((e) => Article.fromJson(e)).toList();
  }
}