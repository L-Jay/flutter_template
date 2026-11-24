import 'package:flutter/widgets.dart';

/// 商品一级分类
class CategoryGroup {
  final int id;
  final String name;
  final String nameEn;

  const CategoryGroup({required this.id, required this.name, this.nameEn = ''});

  factory CategoryGroup.fromJson(Map<String, dynamic> json) {
    return CategoryGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
    );
  }

  /// 按当前语言取展示名，英文缺省时回退中文
  String localizedName(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'en' &&
        nameEn.isNotEmpty) {
      return nameEn;
    }
    return name;
  }
}

/// 商品（SPU），[price] 为起售价
class Product {
  final int id;
  final int categoryId;
  final String title;
  final String cover;
  final String desc;
  final double price;
  final double originPrice;
  final int sales;

  const Product({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.cover,
    required this.desc,
    required this.price,
    required this.originPrice,
    this.sales = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originPrice: (json['originPrice'] as num?)?.toDouble() ?? 0,
      sales: (json['sales'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 可下单的最小规格单元，如「黑色 / M」
class Sku {
  final int id;
  final String name;
  final double price;
  final int stock;

  const Sku({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
  });

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 购物车条目：商品 + 规格 + 数量
class CartItem {
  final Product product;
  final Sku? sku;
  final int quantity;
  final bool selected;

  const CartItem({
    required this.product,
    this.sku,
    this.quantity = 1,
    this.selected = true,
  });

  double get unitPrice => sku?.price ?? product.price;

  double get totalPrice => unitPrice * quantity;

  String get skuName => sku?.name ?? '';

  CartItem copyWith({int? quantity, bool? selected}) {
    return CartItem(
      product: product,
      sku: sku,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
    );
  }
}

/// 订单列表项
class OrderItem {
  final int id;
  final String orderNo;
  final String statusText;
  final String cover;
  final String title;
  final double amount;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.orderNo,
    required this.statusText,
    required this.cover,
    required this.title,
    required this.amount,
    this.quantity = 1,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNo: json['orderNo']?.toString() ?? '',
      statusText: json['statusText']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
