import 'dart:ui';

class Theme {
  String name;
  String code;

  Color fgOld;
  Color fgNew;

  Color bgOld;
  Color bgNew;

  Theme(this.name, this.code, this.fgOld, this.fgNew, this.bgOld, this.bgNew);

  Color getBGColor(int level) {
    Color from = bgOld;
    Color to = bgNew;

    return getColor(level, from, to);
  }

  Color getFGColor(int level) {
    Color from = fgOld;
    Color to = fgNew;

    return getColor(level, from, to);
  }

  Color getColor(int level, Color from, Color to) {
    assert(level >= 0);
    assert(level <= 255);

    double dR = (to.red - from.red).toDouble();
    double dG = (to.green - from.green).toDouble();
    double dB = (to.blue - from.blue).toDouble();

    double l = level / 255.0;
    double r = dR * l + from.red;
    double g = dG * l + from.green;
    double b = dB * l + from.blue;

    return Color.fromARGB(0xff, r.toInt(), g.toInt(), b.toInt());
  }
}
