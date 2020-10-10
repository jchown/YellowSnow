import 'package:YellowSnow/annotations.dart';
import 'package:YellowSnow/workspace.dart';
import 'package:flutter/cupertino.dart';

import 'line.dart';
import 'color_scheme.dart';

class LineDir extends Line {
  String author;
  String filename;

  LineDir(this.filename, this.author, int timestamp) {
    this.timestamp = timestamp;
  }

  @override
  String getFilename() {
    return filename;
  }

  @override
  Widget getWidget(Annotations annotations, ColorScheme theme) {
    int level = annotations.getLevel(timestamp);
    var bgCol = theme.getBGColor(level);
    var fgCol = theme.getFGColor(level);
    return Row(children: <Widget>[
      SizedBox(
          width: 80,
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(author ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      backgroundColor: bgCol,
                      color: fgCol)))),
      SizedBox(
          width: 80,
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(author ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      backgroundColor: bgCol,
                      color: fgCol)))),
      new Expanded(
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(filename.substring(filename.lastIndexOf(Workspace.dirChar) + 1),
                  maxLines: 1,
                  textWidthBasis: TextWidthBasis.parent,
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      backgroundColor: bgCol,
                      color: fgCol)))),
    ]);
  }
}
