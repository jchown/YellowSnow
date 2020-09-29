import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

class Themes {
  static const prefsKey = "theme";

  static Theme yellowSnow = Theme("Yellow Snow", "YS", Color(0xff000000),
      Color(0xff000000), Color(0xffffffff), Color(0xffffff00));

  static Theme purpleStain = Theme(
      "Purple Stain",
      "PS",
      Color(-1),
      Color(0xffffff00),
      Color.fromARGB(255, 30, 30, 30),
      Color.fromARGB(255, 87, 38, 128));

  static Theme get(SharedPreferences preferences) {
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
