import 'package:YellowSnow/annotations.dart';
import 'package:flutter/cupertino.dart';

import 'line.dart';
import 'theme.dart';

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
  Widget getWidget(Annotations annotations, Theme theme) {
    int level = annotations.getLevel(timestamp);
    var bgCol = theme.getBGColor(level);
    var fgCol = theme.getFGColor(level);
    return Row(children: <Widget>[
      SizedBox(
          width: 160,
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
    ]);
  }
}
