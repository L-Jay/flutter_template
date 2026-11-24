/// 优惠券
class CouponItem {
  final int id;
  final String title;
  final double amount;
  final double threshold;
  final String scope;
  final String validTo;

  /// 0 可用 / 1 已使用 / 2 已过期
  final int status;

  const CouponItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.threshold,
    required this.scope,
    required this.validTo,
    this.status = 0,
  });

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    return CouponItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0,
      scope: json['scope']?.toString() ?? '',
      validTo: json['validTo']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 营销活动
class ActivityItem {
  final int id;
  final String title;
  final String subtitle;
  final String cover;
  final String time;

  /// 0 进行中 / 1 即将开始 / 2 已结束
  final int status;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.cover,
    required this.time,
    this.status = 0,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 会员权益
class VipBenefit {
  final String icon;
  final String title;
  final String desc;

  const VipBenefit({
    required this.icon,
    required this.title,
    required this.desc,
  });

  factory VipBenefit.fromJson(Map<String, dynamic> json) {
    return VipBenefit(
      icon: json['icon']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
    );
  }
}

/// 会员信息
class VipInfo {
  final String level;
  final String levelName;
  final int growth;
  final int nextGrowth;
  final int points;
  final String expireDate;
  final double price;
  final List<VipBenefit> benefits;

  const VipInfo({
    required this.level,
    required this.levelName,
    required this.growth,
    required this.nextGrowth,
    required this.points,
    required this.expireDate,
    required this.price,
    this.benefits = const [],
  });

  factory VipInfo.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawBenefits =
        (json['benefits'] as List?) ?? const [];

    return VipInfo(
      level: json['level']?.toString() ?? '',
      levelName: json['levelName']?.toString() ?? '',
      growth: (json['growth'] as num?)?.toInt() ?? 0,
      nextGrowth: (json['nextGrowth'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      expireDate: json['expireDate']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      benefits: rawBenefits
          .whereType<Map>()
          .map((item) => VipBenefit.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

/// 直播间
class LiveRoomItem {
  final int id;
  final String title;
  final String anchor;
  final String avatar;
  final String cover;
  final int viewers;
  final bool live;
  final String time;

  const LiveRoomItem({
    required this.id,
    required this.title,
    required this.anchor,
    required this.avatar,
    required this.cover,
    required this.viewers,
    required this.time,
    this.live = false,
  });

  factory LiveRoomItem.fromJson(Map<String, dynamic> json) {
    return LiveRoomItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      anchor: json['anchor']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      viewers: (json['viewers'] as num?)?.toInt() ?? 0,
      live: json['live'] == true,
      time: json['time']?.toString() ?? '',
    );
  }
}
