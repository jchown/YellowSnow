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
    return Row(children: <Widget>[
      SizedBox(
          width: 160,
          child: Text(author,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontFamily: 'RobotoMono',
                  backgroundColor: theme.getBGColor(0),
                  color: theme.getFGColor(0)))),
      Text(source,
          maxLines: 1,
          style: TextStyle(
              fontFamily: 'RobotoMono',
              backgroundColor: theme.getBGColor(level),
              color: theme.getFGColor(level)))
    ]);
  }
}
