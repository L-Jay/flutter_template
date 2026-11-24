class MessageItem {
  final int id;
  final String title;
  final String content;
  final String time;
  final bool read;

  const MessageItem({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    this.read = false,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      read: json['read'] == true,
    );
  }

  MessageItem copyWith({bool? read}) {
    return MessageItem(
      id: id,
      title: title,
      content: content,
      time: time,
      read: read ?? this.read,
    );
  }
}
