/// 首页轮播
class HomeBannerItem {
  final int id;
  final String title;
  final String imageUrl;
  final String link;

  const HomeBannerItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
  });

  factory HomeBannerItem.fromJson(Map<String, dynamic> json) {
    return HomeBannerItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }
}

/// 首页宫格
class HomeNavItem {
  final String title;
  final String icon;
  final int colorValue;
  final String route;

  /// 跳转搜索页时携带的关键词（如「新品」「热卖」）
  final String keyword;

  const HomeNavItem({
    required this.title,
    required this.icon,
    required this.colorValue,
    required this.route,
    this.keyword = '',
  });

  factory HomeNavItem.fromJson(Map<String, dynamic> json) {
    return HomeNavItem(
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF2F6BFF,
      route: json['route']?.toString() ?? '',
      keyword: json['keyword']?.toString() ?? '',
    );
  }
}

/// 内容流
class FeedItem {
  final int id;
  final String author;
  final String avatar;
  final String content;
  final String cover;
  final String time;
  final int likes;
  final int comments;
  final bool liked;
  final bool favorited;

  const FeedItem({
    required this.id,
    required this.author,
    required this.avatar,
    required this.content,
    required this.cover,
    required this.time,
    required this.likes,
    required this.comments,
    this.liked = false,
    this.favorited = false,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      author: json['author']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      liked: json['liked'] == true,
      favorited: json['favorited'] == true,
    );
  }

  FeedItem copyWith({
    bool? liked,
    bool? favorited,
    int? likes,
    int? comments,
  }) {
    return FeedItem(
      id: id,
      author: author,
      avatar: avatar,
      content: content,
      cover: cover,
      time: time,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      liked: liked ?? this.liked,
      favorited: favorited ?? this.favorited,
    );
  }
}
