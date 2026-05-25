import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    // 1% units for responsive UI
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  // width based on screen
  static double w(double inputWidth) {
    return (inputWidth / 390.0) * screenWidth; // 390 = base width (iPhone 13)
  }

  // height based on screen
  static double h(double inputHeight) {
    return (inputHeight / 844.0) *
        screenHeight; // 844 = base height (iPhone 13)
  }
}
