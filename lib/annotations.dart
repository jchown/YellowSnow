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
    colorMap[0] = 0;

    if (timestamps.isEmpty) {
      stdout.write("No timestamps\n");
      return colorMap;
    }

    int minTime = 1 << 62;
    int maxTime = -1 << 62;

    var sorted = new List<int>();

    for (int timestamp in timestamps) {
      if (timestamp == null) throw Exception("Null time in timestamps");
      if (timestamp == 0)
        continue;

      if (minTime > timestamp) minTime = timestamp;

      if (maxTime < timestamp) maxTime = timestamp;

      sorted.add(timestamp);
    }

    if (sorted.length == 1) {
      colorMap[sorted[0]] = 0;
      return colorMap;
    }

    sorted.sort();

    for (int i = 0; i < sorted.length; i++) {
      var timestamp = sorted[i];

      double t0 = (timestamp.toDouble() - minTime) / (maxTime - minTime);
      double t1 = (i.toDouble()) / (sorted.length - 1);

      double t = t0 * t1 * t0 * t1 * t0 * t1;
      colorMap[timestamp] = (t * 255).floor();
    }

    return colorMap;
  }

  static Annotations pending() {
    return new AnnotationsPending();
  }
}

class AnnotationsPending extends Annotations {
  AnnotationsPending() : super(List.empty());

  @override
  String getSummary(int line) {
    return "";
  }
}
