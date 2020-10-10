import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'color_scheme.dart';

class ColorSchemes {
  static const prefsKey = "cols";

  static ColorScheme yellowSnow = ColorScheme("Yellow Snow", "YS", Color(0xff000000),
      Color(0xff000000), Color(0xffffffff), Color(0xffffff00));

  static ColorScheme purpleStain = ColorScheme(
      "Purple Stain",
      "PS",
      Color(-1),
      Color(0xffffff00),
      Color.fromARGB(255, 30, 30, 30),
      Color.fromARGB(255, 87, 38, 128));

  static ColorScheme get(SharedPreferences preferences) {
    {
      switch (preferences.getString(prefsKey)) {
        case "YS":
          return yellowSnow;

        case "PS":
          return purpleStain;

        default:
          return yellowSnow;
      }
    }
  }

  static set(SharedPreferences preferences, String themeID) {
    preferences.setString(prefsKey, themeID);
    return get(preferences);
  }
}
