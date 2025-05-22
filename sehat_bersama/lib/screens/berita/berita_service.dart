import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'berita_model.dart';

class BeritaService {
  static Future<List<Article>> fetchBerita() async {
    final apiKey = dotenv.env['NEWS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API key tidak ditemukan di .env");
    }

    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=kesehatan&language=id&sortBy=publishedAt&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];

      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat berita');
    }
  }
}
