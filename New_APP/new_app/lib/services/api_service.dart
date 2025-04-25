import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article.dart';

class ApiService {
  static const String _apiKey = '53644779cb9d46b49aadaeb3c87c3f28'; // Replace with your NewsAPI key
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> fetchNews({String category = '', String query = ''}) async {
    String url;
    if (query.isNotEmpty) {
      url = '$_baseUrl/everything?q=$query&apiKey=$_apiKey';
    } else {
      url = '$_baseUrl/top-headlines?country=us${category.isNotEmpty ? '&category=$category' : ''}&apiKey=$_apiKey';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['articles'] as List)
          .map((json) => Article.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}