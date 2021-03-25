import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

class ColorScheme {
  String name;
  String code;

  Color fgOld;
  Color fgNew;

  Color bgOld;
  Color bgNew;

  ColorScheme(this.name, this.code, this.fgOld, this.fgNew, this.bgOld, this.bgNew);

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

  Image? _image;
  Completer<Image>? _rendering;

  Future<Image> getThumbnail() async {
    if (_image != null)
      return Future.value(_image);

    if (_rendering != null)
      return _rendering!.future;

    _rendering = Completer<Image>();

    var w = 64;
    var h = 64;
    var pixels = Uint8List(w * h * 4);
    var random = Random(10101);

    int i = 0;
    for (int y = 0; y < h; y++) {
      var bgCol = getBGColor(random.nextInt(255));
      for (int x = 0; x < w; x++) {
        pixels[i++] = bgCol.red;
        pixels[i++] = bgCol.green;
        pixels[i++] = bgCol.blue;
        pixels[i++] = 0xff;
      }
    }

    decodeImageFromPixels(pixels, w, h, PixelFormat.rgba8888, callback);
    return _rendering!.future;
  }

  callback(Image image) {
    this._image = image;
    _rendering!.complete(image);
    _rendering = null;
  }
}
