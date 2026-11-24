class CommentItem {
  final int id;
  final String author;
  final String avatar;
  final String content;
  final String time;
  final int likes;

  const CommentItem({
    required this.id,
    required this.author,
    required this.avatar,
    required this.content,
    required this.time,
    this.likes = 0,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      author: json['author']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
    );
  }
}
