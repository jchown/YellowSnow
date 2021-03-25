import 'workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'history.dart';

class TopRow extends StatelessWidget {
  const TopRow(
      {Key? key,
      required this.history,
      required this.workspace,
      required this.filename,
      required this.onChangedFilename,
      required this.onHistoryChangedFilename,
      required this.onTappedMenu})
      : super(key: key);

  final History history;
  final Workspace? workspace;
  final String? filename;
  final ValueChanged<String> onChangedFilename;
  final VoidCallback onHistoryChangedFilename;
  final VoidCallback onTappedMenu;

  @override
  Widget build(BuildContext context) {

    var activeCol = Colors.white;
    var inactiveCol = Colors.white.withAlpha(96);

    List<Widget> topRowWidgets = [
      IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),

        onPressed: () => onTappedMenu(),
      ),
      IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: history.hasBack() ? activeCol : inactiveCol,
        ),
        tooltip: history.hasBack() ? history.getBack() : null,
        onPressed: history.hasBack() ? handleBack : null,
      ),
      IconButton(
        icon: Icon(
          Icons.chevron_right,
          color:  history.hasFwd() ? activeCol : inactiveCol,
        ),
        tooltip: history.hasFwd() ? history.getFwd() : null,
        onPressed: history.hasFwd() ? handleFwd : null,
      ),
    ];

    if (filename != "" && workspace != null) {
      var style = TextStyle(color: Colors.white);
      topRowWidgets.add(OutlineButton(
          child: Row(children: <Widget>[Icon(Icons.home, color: Colors.white), SizedBox(width: 8), Text(workspace!.rootDir, style: style)]),
          onPressed: () => onChangedFilename(workspace!.rootDir)));
      if (filename != workspace!.rootDir) {
        var segments = workspace!.getRelativePath(filename!).split(Workspace.dirChar);
        for (int i = 0; i < segments.length; i++) {
          bool last = i == (segments.length - 1);
          var path = workspace!.getAbsolutePath(segments.getRange(0, i + 1).join(Workspace.dirChar));
          String segment = segments[i];
          if (!last) segment += Workspace.dirChar;
          topRowWidgets.add(OutlineButton(child: Text(segment, style: style), onPressed: () => onChangedFilename(path)));
        }
      }
    }
    return Row(
        key: GlobalKey(),
        children: <Widget>[Expanded(child: Container(color: Colors.blueGrey, child: Row(children: topRowWidgets)))]);
  }

  void handleBack() {
    history.back();
    onHistoryChangedFilename();
  }

  void handleFwd() {
    history.fwd();
    onHistoryChangedFilename();
  }
}
