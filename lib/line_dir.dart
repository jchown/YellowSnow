import 'annotations.dart';
import 'render_style.dart';
import 'workspace.dart';
import 'package:flutter/cupertino.dart';

import 'line.dart';
import 'color_scheme.dart';

class LineDir extends Line {
  String? author;
  String filename;
  String? subject;

  LineDir(this.filename, this.author, this.subject, int timestamp) {
    if (this.filename.contains("${Workspace.dirChar}${Workspace.dirChar}")) throw Exception("Bad filename: $filename");
    this.timestamp = timestamp;
  }

  @override
  String getFilename() {
    return filename;
  }

  @override
  Widget getWidget(Annotations annotations, RenderStyle renderStyle) {
    int level = annotations.getLevel(timestamp);
    var bgCol = renderStyle.colorScheme.getBGColor(level);
    var fgCol = renderStyle.colorScheme.getFGColor(level);
    return Row(children: <Widget>[
      SizedBox(
          width: 80,
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(author ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style:
                      TextStyle(fontFamily: 'RobotoMono', backgroundColor: bgCol, color: fgCol, fontSize: renderStyle.fontSize)))),
      SizedBox(
          width: 80,
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(author ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style:
                      TextStyle(fontFamily: 'RobotoMono', backgroundColor: bgCol, color: fgCol, fontSize: renderStyle.fontSize)))),
      new Expanded(
          child: Container(
              color: bgCol,
              width: double.infinity,
              child: Text(filename.substring(filename.lastIndexOf(Workspace.dirChar) + 1),
                  maxLines: 1,
                  textWidthBasis: TextWidthBasis.parent,
                  style:
                      TextStyle(fontFamily: 'RobotoMono', backgroundColor: bgCol, color: fgCol, fontSize: renderStyle.fontSize)))),
    ]);
  }
}
