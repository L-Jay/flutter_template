import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lj_flutter_package/utils/lj_network.dart';

import '../api_url.dart';

/// 调试期 mock 数据统一入口。
///
/// 静态接口在 `assets/json/mock.json` 中声明（key = 接口 path，value = 完整响应体），
/// 需要按入参返回的接口（验证码、分页列表、详情等）在这里注册回调生成数据。
/// 只在 debug 下生效，release 直接跳过。
class MockConfig {
  /// mock 请求延迟：默认 500ms，个别接口需要更长/更短时在 [delays] 按 path 覆盖
  static const Duration delay = Duration(milliseconds: 500);
  static const Map<String, Duration> delays = {};

  /// 当前 mock 验证码：/api/sms 生成，/api/user/login/mobile 校验
  static String? _smsCode;

  /// 应用启动时调用一次（bootstrap 的 _configMock 内只有这一行）
  static Future<void> setup() async {
    if (!kDebugMode) return;

    await _loadStaticMocks();
    _registerSmsMock();
    _registerListMocks();
  }

  /// 读取 mock.json 整体写入 LJNetwork.mockMap
  static Future<void> _loadStaticMocks() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/mock.json',
    );
    final Map<String, dynamic> mocks = json.decode(jsonString) as Map<String, dynamic>;

    mocks.forEach((path, response) {
      LJNetwork.mockMap[path] = (params) async {
        await Future.delayed(delays[path] ?? delay);
        return json.encode(response);
      } as LJNetworkMockCallback;
    });
  }

  /// 验证码登录：随机码在 data 中返回，登录页拿到后会提示，便于联调输入
  static void _registerSmsMock() {
    LJNetwork.mockMap[ApiUrl.phoneCode] = (params) {
      _smsCode = (Random().nextInt(900000) + 100000).toString();
      return jsonEncode({
        'code': 200,
        'message': '验证码已发送',
        'data': _smsCode,
      });
    };

    LJNetwork.mockMap[ApiUrl.mobileLogin] = (params) {
      final bool passed = params?['code']?.toString() == _smsCode;
      if (!passed) {
        return jsonEncode({'code': 400, 'message': '验证码错误'});
      }
      return jsonEncode({
        'code': 200,
        'message': '登录成功',
        'data': {'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'},
      });
    };
  }

  /// 分页 / 分类 / 订单 / 详情类接口按入参生成数据：
  /// 列表第 1、2 页各返回一页，第 3 页返回空数组，可以看到一次「加载更多」
  static void _registerListMocks() {
    _registerCallback(
      ApiUrl.homeFeed,
      (params) => _feedPage(page: _page(params), idBase: 11, seed: 'home'),
    );
    _registerCallback(
      ApiUrl.feedList,
      (params) => _feedPage(page: _page(params), idBase: 201, seed: 'feed'),
    );
    _registerCallback(ApiUrl.feedDetail, _feedDetail);
    _registerCallback(ApiUrl.search, _searchPage);
    _registerCallback(ApiUrl.productList, _productList);
    _registerCallback(ApiUrl.productDetail, _productDetail);
    _registerCallback(ApiUrl.orderList, _orderList);
  }

  /// 注册按入参返回的 mock：统一包一层延迟和标准响应结构
  static void _registerCallback(
    String path,
    Object? Function(Map<String, dynamic>? params) callback,
  ) {
    LJNetwork.mockMap[path] = (params) async {
      await Future.delayed(delays[path] ?? delay);
      return jsonEncode({'code': 200, 'message': '', 'data': callback(params)});
    };
  }

  static int _page(Map<String, dynamic>? params) {
    return int.tryParse('${params?['page']}') ?? 1;
  }

  static const List<String> _authors = [
    '设计师 K', '生活家 L', '旅行者 M', '美食家 N', '极客 O', '摄影师 P',
  ];

  /// 内容流分页数据：每页 6 条，超过 2 页返回空数组模拟没有更多
  static List<Map<String, dynamic>> _feedPage({
    required int page,
    required int idBase,
    required String seed,
  }) {
    if (page > 2) return [];

    return List.generate(6, (i) {
      final int id = idBase + (page - 1) * 6 + i;

      return {
        'id': id,
        'author': _authors[id % _authors.length],
        'avatar': 'https://picsum.photos/seed/$seed-avatar$id/200/200',
        'content': '这是一条示例内容 #$id，上拉加载更多后展示的第二页数据。',
        'cover': 'https://picsum.photos/seed/$seed$id/800/800',
        'time': '${id % 24} 小时前',
        'likes': 20 + id % 80,
        'comments': id % 12,
        'liked': false,
        'favorited': false,
      };
    });
  }

  /// 内容详情：按 id 生成与列表一致的标题、封面等信息
  static Map<String, dynamic> _feedDetail(Map<String, dynamic>? params) {
    final int id = int.tryParse('${params?['id']}') ?? 1;
    final String seed = id >= 200 ? 'feed' : 'home';

    return {
      'id': id,
      'author': _authors[id % _authors.length],
      'avatar': 'https://picsum.photos/seed/$seed-avatar$id/200/200',
      'content': '这是内容 #$id 的详情正文，包含作者、封面、互动数据等完整信息，'
          '用于演示不同内容之间详情页的差异。',
      'cover': 'https://picsum.photos/seed/$seed$id/800/800',
      'time': '${id % 24} 小时前',
      'likes': 20 + id % 80,
      'comments': id % 12,
      'liked': false,
      'favorited': false,
    };
  }

  /// 分类名称池，与 /api/category/list 保持一致
  static const Map<int, String> _categoryNames = {
    1: '手机数码',
    2: '服饰鞋包',
    3: '美妆护肤',
    4: '食品生鲜',
    5: '家居日用',
    6: '运动户外',
    7: '母婴玩具',
    8: '图书文娱',
  };

  /// 按 id 程序化生成商品变体：价格、封面、销量随 id 变化
  static Map<String, dynamic> _product(int id, {String? keyword}) {
    final int categoryId = ((id ~/ 100) % 8) + 1;
    final double price = 49 + (id * 37) % 800 + 0.9;

    return {
      'id': id,
      'categoryId': categoryId,
      'title': keyword != null
          ? '$keyword精选好物 #$id'
          : '${_categoryNames[categoryId] ?? '精选'}商品 #${id % 100 + 1}',
      'cover': 'https://picsum.photos/seed/product$id/800/800',
      'desc': '商品 #$id 的详情描述，来自${_categoryNames[categoryId] ?? '精选'}分类。',
      'price': price,
      'originPrice': price + 80,
      'sales': (id * 17) % 2000,
    };
  }

  /// 搜索结果：按关键词生成商品，每页 8 条共 2 页
  static List<Map<String, dynamic>> _searchPage(Map<String, dynamic>? params) {
    final int page = _page(params);
    if (page > 2) return [];

    final String keyword = '${params?['keyword'] ?? ''}';
    return List.generate(8, (i) => _product(page * 10000 + i, keyword: keyword));
  }

  /// 商品列表：按 categoryId 生成，每页 10 条共 2 页
  static List<Map<String, dynamic>> _productList(Map<String, dynamic>? params) {
    final int page = _page(params);
    if (page > 2) return [];

    final int categoryId = int.tryParse('${params?['categoryId']}') ?? 1;

    return List.generate(
      10,
      (i) => _product(categoryId * 100 + (page - 1) * 10 + i + 1),
    );
  }

  /// 商品详情：按 id 生成，SKU 价格随商品价偏移
  static Map<String, dynamic> _productDetail(Map<String, dynamic>? params) {
    final int id = int.tryParse('${params?['id']}') ?? 101;
    final Map<String, dynamic> product = _product(id);
    final double price = (product['price'] as double).toDouble();

    return {
      ...product,
      'cover': 'https://picsum.photos/seed/product$id/900/900',
      'desc': '这是商品 #$id 的详细介绍，包含材质、尺寸、保养方式等说明信息。',
      'skus': [
        {'id': id * 10 + 1, 'name': '黑色 / M', 'price': price, 'stock': 20},
        {'id': id * 10 + 2, 'name': '黑色 / L', 'price': price + 10, 'stock': 15},
        {'id': id * 10 + 3, 'name': '白色 / M', 'price': price, 'stock': 8},
        {'id': id * 10 + 4, 'name': '白色 / L', 'price': price + 10, 'stock': 0},
      ],
    };
  }

  /// 订单状态池：key 与接口参数一致
  static const List<String> _orderStatuses = ['pay', 'send', 'receive', 'done'];

  static String _orderStatusText(String status) {
    switch (status) {
      case 'pay':
        return '待付款';
      case 'send':
        return '待发货';
      case 'receive':
        return '待收货';
      case 'done':
        return '已完成';
      default:
        return '待付款';
    }
  }

  /// 订单列表：按 status 筛选，每页 10 条共 2 页
  static List<Map<String, dynamic>> _orderList(Map<String, dynamic>? params) {
    final int page = _page(params);
    if (page > 2) return [];

    final String status = '${params?['status'] ?? 'all'}';

    return List.generate(10, (i) {
      final int id = 9000 + (page - 1) * 10 + i;
      final String orderStatus = status == 'all'
          ? _orderStatuses[id % _orderStatuses.length]
          : status;

      return {
        'id': id,
        'orderNo': 'NO$id',
        'statusText': _orderStatusText(orderStatus),
        'cover': 'https://picsum.photos/seed/order$id/300/300',
        'title': '${_categoryNames[(id % 8) + 1] ?? '精选'}商品 #${id % 100 + 1}',
        'amount': 49 + (id * 37) % 800 + 0.9,
        'quantity': id % 3 + 1,
      };
    });
  }
}
