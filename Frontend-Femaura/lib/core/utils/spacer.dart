import 'package:flutter/widgets.dart';

class HSpace extends SizedBox {
  const HSpace(double dimension, {super.key}) : super(width: dimension);
}

class VSpace extends SizedBox {
  const VSpace(double dimension, {super.key}) : super(height: dimension);
}

abstract class Dimen {
  /// 0.5 * 8 = 4
  static const double x_5 = 0.5;

  /// 1 * 8 = 8
  static const double x1 = 8;

  /// 1.5 * 8 = 12
  static const double x1_5 = 12;

  /// 2 * 8 = 16
  static const double x2 = 16;

  /// 2.5 * 8 = 20
  static const double x2_5 = 20;

  /// 3 * 8 = 24
  static const double x3 = 24;

  /// 3.5 * 8 = 28
  static const double x3_5 = 28;

  /// 4 * 8 = 32
  static const double x4 = 32;

  /// 4.5 * 8 = 36
  static const double x4_5 = 36;

  /// 5 * 8 = 40
  static const double x5 = 40;

  /// 5.5 * 8 = 44
  static const double x5_5 = 44;

  /// 6 * 8 = 48
  static const double x6 = 48;

  /// 6.5 * 8 = 52
  static const double x6_5 = 52;

  /// 7 * 8 = 56
  static const double x7 = 56;

  /// 7.5 * 8 = 60
  static const double x7_5 = 60;

  /// 8 * 8 = 64
  static const double x8 = 64;

  /// 8.5 * 8 = 68
  static const double x8_5 = 68;

  /// 9 * 8 = 72
  static const double x9 = 72;

  // Radius
  /// 1 * 5 = 5
  static const double rad1 = 5;

  /// 1.5 * 5 = 7.5
  static const double rad1_5 = 7.5;

  /// 2 * 5 = 10
  static const double rad2 = 10;

  /// 2.5 * 5 = 12.5
  static const double rad2_5 = 12.5;

  /// 3 * 5 = 15
  static const double rad3 = 15;

  /// 3.5 * 5 = 17.5
  static const double rad3_5 = 17.5;

  /// 4 * 5 = 20
  static const double rad4 = 20;

  /// 4.5 * 5 = 22.5
  static const double rad4_5 = 22.5;

  /// 5 * 5 = 25
  static const double rad5 = 25;

  /// 5.5 * 5 = 27.5
  static const double rad5_5 = 27.5;

  /// 6 * 5 = 30
  static const double rad6 = 30;

  /// 6.5 * 5 = 32.5
  static const double rad6_5 = 32.5;

  /// 7 * 5 = 35
  static const double rad7 = 35;

  /// 7.5 * 5 = 37.5
  static const double rad7_5 = 37.5;

  /// 8 * 5 = 40
  static const double rad8 = 40;

  /// 8.5 * 5 = 42.5
  static const double rad8_5 = 42.5;

  /// 9 * 5 = 45
  static const double rad9 = 45;

  /// 9.5 * 5 = 47.5
  static const double rad9_5 = 47.5;

  /// 10 * 5 = 50
  static const double rad10 = 50;
}
