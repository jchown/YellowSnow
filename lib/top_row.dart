import 'package:YellowSnow/workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TopRow extends StatelessWidget {
  const TopRow({Key key, @required this.workspace, @required this.filename, @required this.onChangedFilename})
      : super(key: key);

  final Workspace workspace;
  final String filename;
  final ValueChanged<String> onChangedFilename;

  @override
  Widget build(BuildContext context) {
    List<Widget> topRowWidgets = [
      IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
//        onPressed: () => scaffoldKey.currentState.openDrawer(),
      )
    ];

    if (filename != "") {
      topRowWidgets.add(IconButton(
        icon: Icon(
          Icons.home,
          color: Colors.white,
        ),
        onPressed: () => onChangedFilename(workspace.rootDir),
      ));
      topRowWidgets
          .add(ElevatedButton(child: Text(workspace.rootDir), onPressed: () => onChangedFilename(workspace.rootDir)));
      if (filename != workspace.rootDir) {
        var segments = workspace.getRelativePath(filename).split(Workspace.dirChar);
        for (int i = 0; i < segments.length; i++) {
          bool last = i == (segments.length - 1);
          var path = workspace.getAbsolutePath(segments.getRange(0, i + 1).join(Workspace.dirChar));
          String segment = segments[i];
          if (!last) segment += Workspace.dirChar;
          topRowWidgets.add(ElevatedButton(child: Text(segment), onPressed: () => onChangedFilename(path)));
        }
      }
    }
    return Row(
        key: GlobalKey(),
        children: <Widget>[Expanded(child: Container(color: Colors.blueGrey, child: Row(children: topRowWidgets)))]);
  }
}
