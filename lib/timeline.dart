import 'annotate_git.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Timeline extends StatefulWidget {
  Timeline(this.commits, this.onChangedCommit, {Key key}) : super(key: key);

  final List<Change> commits;
  final ValueChanged<String> onChangedCommit;

  @override
  _TimelineState createState() => _TimelineState(commits, commits.length - 1, onChangedCommit);
}

class _TimelineState extends State<Timeline> {
  List<Change> _changes;
  int _change;
  ValueChanged<String> _onChangedSha;

  _TimelineState(this._changes, this._change, this._onChangedSha);

  @override
  Widget build(BuildContext context) {
    if (_changes.length < 2) return Slider(value: 0, min: 0, max: 0, onChanged: (v) => {});

    var commit = _changes[_change];
    var dateFormat = DateFormat("yyyy.MM.dd HH:mm:ss");
    var date = dateFormat.format(new DateTime.fromMillisecondsSinceEpoch(commit.timestamp * 1000));

    return Row(children: <Widget>[
      IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.grey[100],
          ),
          tooltip: "Previous Commit",
          onPressed: onLeftButton),
      Expanded(
          child: Slider(
        activeColor: Colors.white,
        inactiveColor: Colors.grey.withAlpha(128),
        value: _change.toDouble(),
        min: 0,
        max: (_changes.length - 1).toDouble(),
        divisions: (_changes.length - 1),
        label: "SHA: ${commit.sha}\n${commit.filename}\n$date\n\n${commit.editor} ${commit.editorEmail}\n${commit.comment}",
        onChanged: (double value) => setChange(value.toInt())
      )),
      IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
          tooltip: "Next Commit",
          onPressed: onRightButton)
    ]);
  }

  void onLeftButton() {
    if (_change > 0) {
      setChange(_change - 1);
    }
  }

  void onRightButton() {
    if (_change < _changes.length - 1) {
      setChange(_change + 1);
    }
  }

  setChange(int change) {
    if (_change != change) {
      setState(() {
        _change = change;
        _changes = _changes;
        _onChangedSha(_changes[change].sha);
      });
    }
  }
}
