class ApiUrl {
  /// 生产
  static String baseUrl = 'https://www.ljay.com';

  ///配置
  static String config = '/api/config';

  ///验证码
  static String phoneCode = '/api/sms';

  ///手机号登录
  static String mobileLogin = '/api/user/login/mobile';

  /// 微信登录（参数为微信授权 code）
  static String wechatLogin = '/api/user/login/wechat';

  ///刷新token
  static String refreshToken = '/api/user/login/refresh_token';

  ///退出登录
  static String logout = '/api/user/login/logout';

  ///用户基本信息
  static String userInfo = '/api/user/userInfo';

  ///修改个人信息（昵称/手机号/头像）
  static String userUpdate = '/api/user/update';

  ///绑定微信
  static String bindWechat = '/api/user/bind/wechat';

  ///系统维护
  static String systemMaintain = '/api/system/maintain';

  ///首页轮播
  static String homeBanners = '/api/home/banners';

  ///首页宫格
  static String homeNavs = '/api/home/navs';

  ///首页内容流（分页）
  static String homeFeed = '/api/home/feed';

  ///内容 Tab 列表
  static String feedList = '/api/feed/list';

  ///商品一级分类
  static String categoryList = '/api/category/list';

  ///消息列表
  static String messageList = '/api/message/list';

  ///优惠券列表
  static String couponList = '/api/coupon/list';

  ///活动列表
  static String activityList = '/api/activity/list';

  ///会员信息
  static String vipInfo = '/api/vip/info';

  ///直播间列表
  static String liveList = '/api/live/list';

  ///搜索
  static String search = '/api/search';

  ///收藏列表
  static String favoriteList = '/api/favorite/list';

  ///商品列表（按 categoryId 筛选）
  static String productList = '/api/product/list';

  ///商品详情
  static String productDetail = '/api/product/detail';

  ///创建订单
  static String orderCreate = '/api/order/create';

  ///订单列表
  static String orderList = '/api/order/list';

  ///内容详情
  static String feedDetail = '/api/feed/detail';

  ///内容点赞
  static String feedLike = '/api/feed/like';

  ///内容收藏
  static String feedFavorite = '/api/feed/favorite';

  ///评论列表
  static String commentList = '/api/comment/list';

  ///发表评论
  static String commentCreate = '/api/comment/create';
}
