import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yellow_snow/render_style.dart';

import 'annotations.dart';
import 'line.dart';
import 'string_ext.dart';

class LineFile extends Line {
  String author;
  String? email;
  int? lineNo;
  String source;
  String comment;

  LineFile(this.author, this.source, this.comment, int timestamp) {
    this.timestamp = timestamp;
  }

  @override
  String getFilename() {
    return source;
  }

  @override
  Widget getWidget(Annotations annotations, RenderStyle renderStyle) {
    int level = annotations.getLevel(timestamp);
    var bgCol = renderStyle.colorScheme.getBGColor(level);
    var fgCol = renderStyle.colorScheme.getFGColor(level);
    var dateFormat = DateFormat("yyyy.MM.dd HH:mm:ss");

    return Row(children: <Widget>[
      SizedBox(width: 4),
      SizedBox(
          width: 120,
          child: Tooltip(message: "$author - ${dateFormat.format(new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000))}\n\n$comment",
              child: Container(
                  color: bgCol,
                  width: double.infinity,
                  child: Text(author,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontFamily: 'RobotoMono', backgroundColor: bgCol, color: fgCol, fontSize: renderStyle.fontSize))))),
      SizedBox(width: 4),
      new Expanded(
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(source.replaceTabs(renderStyle.tabSize),
                  maxLines: 1,
                  textWidthBasis: TextWidthBasis.parent,
                  style: TextStyle(fontFamily: 'RobotoMono', backgroundColor: bgCol, color: fgCol, fontSize: renderStyle.fontSize)))),
      SizedBox(width: 4)
    ]);
  }
}
