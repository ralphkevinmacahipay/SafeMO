import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenX;
  static double? screenY;
  static double? blockX;
  static double? blockY;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenX = _mediaQueryData!.size.width;
    screenY = _mediaQueryData!.size.height;

    blockX = screenX! / 100;
    blockY = screenY! / 100;
  }
}
