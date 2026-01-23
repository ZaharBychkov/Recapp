class Comment {
  final String author;
  final String text;
  final DateTime createdAt;
  final String? imageUrl;

  Comment({required this.author, required this.text, this.imageUrl}) : createdAt = DateTime.now();
}