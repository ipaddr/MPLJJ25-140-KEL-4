class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String publishedAt;
  final String content;
  final String author;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
    required this.author,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? 'Reporter',
      url: json['url'] ?? '',
    );
  }
}
