
import 'package:shared_preferences/shared_preferences.dart';

import 'color_scheme.dart';
import 'color_schemes.dart';

class RenderStyle {
  static const colorSchemePrefsKey = "colScheme";
  static const fontSizePrefsKey = "fontSize";
  static const tabSizePrefsKey = "tabSize";
  
  static const defaultFontSize = 12.0;
  static const defaultTabSize = 4;

  final ColorScheme colorScheme;
  final double fontSize;
  final int tabSize;

  RenderStyle(this.colorScheme, this.fontSize, this.tabSize);

  static Future<RenderStyle> load() async {
    var prefs = await SharedPreferences.getInstance();
    var colorScheme = ColorSchemes.get(prefs.getString(colorSchemePrefsKey));
    var fontSize = prefs.getDouble(fontSizePrefsKey) ?? defaultFontSize;
    var tabSize = prefs.getInt(tabSizePrefsKey) ?? defaultTabSize;

    return RenderStyle(colorScheme, fontSize, tabSize);
  }

  RenderStyle withColorSchemeID(String schemeCode) {
    SharedPreferences.getInstance().then((prefs) => prefs.setString(colorSchemePrefsKey, schemeCode));
    var colorScheme = ColorSchemes.get(schemeCode);
    return RenderStyle(colorScheme, fontSize, tabSize);
  }

  RenderStyle setFontHeight(double fontSize) {
    SharedPreferences.getInstance().then((prefs) => prefs.setDouble(fontSizePrefsKey, fontSize));
    return RenderStyle(colorScheme, fontSize, tabSize);
  }
}
