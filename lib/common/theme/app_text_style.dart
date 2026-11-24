import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

/// 统一的文字样式（字号 / 行高 / 字重）。
///
/// 字重使用 `lj_define.dart` 中的平台自适应常量，因此所有方法都不能是
/// const，调用处也不要给 TextStyle 加 const。
class AppTextStyle {
  static const double displaySize = 24; // 行高 32
  static const double titleSize = 20; // 行高 28
  static const double headlineSize = 17; // 行高 24
  static const double bodySize = 15; // 行高 22
  static const double captionSize = 13; // 行高 20
  static const double smallSize = 11; // 行高 16

  static TextStyle display(Color color) {
    return TextStyle(
      fontSize: displaySize,
      height: 32 / displaySize,
      fontWeight: semibold,
      color: color,
    );
  }

  static TextStyle title(Color color) {
    return TextStyle(
      fontSize: titleSize,
      height: 28 / titleSize,
      fontWeight: semibold,
      color: color,
    );
  }

  static TextStyle headline(Color color) {
    return TextStyle(
      fontSize: headlineSize,
      height: 24 / headlineSize,
      fontWeight: medium,
      color: color,
    );
  }

  static TextStyle body(Color color) {
    return TextStyle(
      fontSize: bodySize,
      height: 22 / bodySize,
      fontWeight: regular,
      color: color,
    );
  }

  static TextStyle caption(Color color) {
    return TextStyle(
      fontSize: captionSize,
      height: 20 / captionSize,
      fontWeight: regular,
      color: color,
    );
  }

  static TextStyle small(Color color) {
    return TextStyle(
      fontSize: smallSize,
      height: 16 / smallSize,
      fontWeight: regular,
      color: color,
    );
  }

  static TextStyle button(Color color) {
    return TextStyle(
      fontSize: headlineSize,
      height: 24 / headlineSize,
      fontWeight: medium,
      color: color,
    );
  }
}
