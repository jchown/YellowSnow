import 'package:YellowSnow/annotate_git.dart';
import 'package:YellowSnow/annotations_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Timeline extends StatefulWidget {
  Timeline(this.commits, this.onChangedCommit, {Key key}) : super(key: key);

  final List<Commit> commits;
  final ValueChanged<String> onChangedCommit;

  @override
  _TimelineState createState() => _TimelineState(commits, commits.length - 1, onChangedCommit);
}

class _TimelineState extends State<Timeline> {
  List<Commit> _commits;
  int _change;
  ValueChanged<String> _onChangedCommit;

  _TimelineState(this._commits, this._change, this._onChangedCommit);

  @override
  Widget build(BuildContext context) {
    if (_commits.length < 2) return Slider(value: 0, min: 0, max: 0);

    var commit = _commits[_change];
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
        max: (_commits.length - 1).toDouble(),
        divisions: _commits.length,
        label: "SHA: ${commit.sha}\n$date\n\n${commit.editor} ${commit.editorEmail}\n${commit.comment}",
        onChanged: (double value) {
          int i = value.toInt();
          if (_change == i) return;
          setState(() {
            _change = i;
            _commits = _commits;
          });
        },
        onChangeEnd: (double value) {
          int i = value.toInt();
          if (_change == i) return;
          setState(() {
            _change = i;
            _commits = _commits;
            _onChangedCommit(commit.sha);
          });
        },
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
      setState(() {
        _change = _change - 1;
        _commits = _commits;
        _onChangedCommit(_commits[_change - 1].sha);
      });
    }
  }

  void onRightButton() {
    if (_change < _commits.length - 1) {
      setState(() {
        _change = _change + 1;
        _commits = _commits;
        _onChangedCommit(_commits[_change + 1].sha);
      });
    }
  }
}
