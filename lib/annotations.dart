import 'dart:io';

import 'line.dart';

/// Base class of a list of annotated lines
abstract class Annotations {
  String getSummary(int line);

  int getLevel(int timestamp) {
    return _timeToLevel[timestamp];
  }

  List<Line> get lines => _lines;

  List<Line> _lines;
  Map<int, int> _timeToLevel;

  Annotations(List<Line> lines) {
    this._lines = lines;
    this._timeToLevel =
        calculateColorMap(lines.map((e) => e.timestamp).toSet());
  }

  /// Turn a set of timestamps into a gray scale.

  Map<int, int> calculateColorMap(Set<int> timestamps) {

    var colorMap = new Map<int, int>();

    if (timestamps.isEmpty) {
      stdout.write("No timestamps\n");
      return colorMap;
    }

    int minTime = 1 << 62;
    int maxTime = -1 << 62;

    var sorted = new List<int>();

    for (int timestamp in timestamps) {
      if (timestamp == null) throw Exception("Null time in timestamps");

      if (minTime > timestamp) minTime = timestamp;

      if (maxTime < timestamp) maxTime = timestamp;

      sorted.add(timestamp);
    }

    if (sorted.length == 1) {
      stdout.write("Timestamps: ${sorted[0]}\n");

      colorMap[sorted[0]] = 0;
      return colorMap;
    }

    sorted.sort();

    stdout.write("Timestamps: ${sorted.join(',')}\n");

    for (int i = 0; i < sorted.length; i++) {
      var timestamp = sorted[i];

      double t0 = (timestamp.toDouble() - minTime) / (maxTime - minTime);
      double t1 = (i.toDouble()) / sorted.length;

      double t = t0 * t1 * t0 * t1;
      colorMap[timestamp] = (t * 255).floor();
    }

    stdout.write("Levels: ${colorMap.values.join(',')}\n");

    return colorMap;
  }

  static Annotations pending() {
    return new AnnotationsPending();
  }

/*
  public string GetHTML()
  {
    var theme.dart = Themes.Selected;
    var html = new StringBuilder("<html>");
    html.Append("<head><style>\n");
    html.Append(string.Format("body {{ background-color: {0}; color: {1}; }}\n", ToHtml(theme.dart.bgOld), ToHtml(theme.dart.fgNew)));
    html.Append(string.Format(".line {{  white-space: pre; font-family: Courier; width:100%; font-size: {0}pt; }}\n", Font.PointSize));

    for (int i = 0; i < 256; i++)
    {
      var fg = Colorizer.GetFGColor(i);
      var bg = Colorizer.GetBGColor(i);
      html.Append(string.Format(".level_{0} {{ background-color: {1}; color: {2}; }}\n", i, ToHtml(bg), ToHtml(fg)));
    }
    html.Append("</style></head>\n");

    html.Append("<body><div style='width=100%;height=100%;'>\n");
    for (int i = 0; i < GetNumLines(); i++)
    {
      html.Append(string.Format("<div class='line level_{0}' id='line_{1}'>\n", GetLevel(i), i));
      html.Append(string.Format("<a name='line_{0}' href='#line_{0}'></a>\n", i));
      html.Append(GetHTML(i));
      html.Append("</div>");
    }

    html.Append("</div></body></html>");
    return html.ToString();
  }

  private string ToHtml(Color color)
  {
    return string.Format("#{0:X2}{1:X2}{2:X2}", color.R, color.G, color.B);
  }

  public Image CreateImage(int width, int height)
  {
    bitmap = new Bitmap(width, height);

    if (GetNumLines() > 0)
    {
      for (int y = 0; y < height; y++)
      {
        var level = GetLevel((y * GetNumLines()) / height);
        var color = Colorizer.GetBGColor(level);
        for (int x = 0; x < width; x++)
          bitmap.SetPixel(x, y, color);
      }
    }
    else
    {
      using (var graphics = Graphics.FromImage(bitmap))
    graphics.Clear(Color.White);
    }

    return bitmap;
  }
   */

//  private Bitmap bitmap = null;
}

class AnnotationsPending extends Annotations {
  AnnotationsPending() : super(List.empty());

  @override
  String getSummary(int line) {
    return "";
  }
}
