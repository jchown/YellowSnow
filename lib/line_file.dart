import 'package:flutter/cupertino.dart';

import 'annotations.dart';
import 'line.dart';
import 'color_scheme.dart';

class LineFile extends Line {
  String author;
  int lineNo;
  String source;

  LineFile(String editor, String source, int timestamp) {
    this.timestamp = timestamp;
    this.author = editor;
    this.source = source;
  }


  @override
  String getFilename() {
    return null;
  }

  @override
  Widget getWidget(Annotations annotations, ColorScheme theme) {
    int level = annotations.getLevel(timestamp);
    var bgCol = theme.getBGColor(level);
    var fgCol = theme.getFGColor(level);
    return Row(
        children: <Widget>[
      SizedBox(width: 4),
      SizedBox(
          width: 120,
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(author,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      backgroundColor: bgCol,
                      color: fgCol)))),
      SizedBox(width: 4),
      new Expanded(
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(source,
                  maxLines: 1,
                  textWidthBasis: TextWidthBasis.parent,
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      backgroundColor: bgCol,
                      color: fgCol)))),
      SizedBox(width: 4)
    ]);
  }
}
