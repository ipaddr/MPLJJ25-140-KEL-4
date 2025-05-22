import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'berita_model.dart';

class BeritaDetailScreen extends StatelessWidget {
  final Article article;

  const BeritaDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artikel Berita")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: article.urlToImage,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (_, __) => const CircularProgressIndicator(),
              errorWidget: (_, __, ___) => const Icon(Icons.image),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(article.author),
                      const Spacer(),
                      Text(article.publishedAt.split("T").first),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(article.content.isNotEmpty ? article.content : article.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
