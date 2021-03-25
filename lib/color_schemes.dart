import 'dart:ui';

import 'color_scheme.dart';

class ColorSchemes {
  static ColorScheme yellowSnow = ColorScheme(
      "Yellow Snow",
      "YS",
      Color(0xff000000),
      Color(0xff000000),
      Color(0xffffffff),
      Color(0xffffff00));

  static ColorScheme purpleStain = ColorScheme(
      "Purple Stain",
      "PS",
      Color(-1),
      Color(0xffffff00),
      Color.fromARGB(255, 30, 30, 30),
      Color.fromARGB(255, 87, 38, 128));

  static ColorScheme get(String? schemeCode) {
    switch (schemeCode) {
      case "YS":
        return yellowSnow;

      case "PS":
        return purpleStain;

      default:
        return yellowSnow;
    }
  }
}
