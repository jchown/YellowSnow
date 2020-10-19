import 'package:YellowSnow/annotations_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Timeline extends StatefulWidget {
  Timeline(this.annotations, this.onChangedCommit, {Key key}) : super(key: key);

  final AnnotationsFile annotations;
  final ValueChanged<String> onChangedCommit;

  @override
  _TimelineState createState() => _TimelineState(annotations, annotations.getChanges().length - 1, onChangedCommit);
}

class _TimelineState extends State<Timeline> {
  AnnotationsFile _annotations;
  int _change;
  ValueChanged<String> _onChangedCommit;

  _TimelineState(this._annotations, this._change, this._onChangedCommit);

  @override
  Widget build(BuildContext context) {
    if (_annotations.getChanges().length < 2) return Slider(value: 0, min: 0, max: 0);

    var commit = _annotations.getChanges()[_change];
    var dateFormat = DateFormat("yyyy.MM.dd HH:mm:ss");
    var date = dateFormat.format(new DateTime.fromMillisecondsSinceEpoch(commit.timestamp * 1000));

    return Slider(
      value: _change.toDouble(),
      min: 0,
      max: (_annotations.getChanges().length - 1).toDouble(),
      divisions: _annotations.getChanges().length,
      label: "SHA: ${commit.sha}\n$date\n\n${commit.editor} ${commit.editorEmail}\n${commit.comment}",
      onChanged: (double value) {
        int i = value.toInt();
        if (_change == i) return;
        setState(() {
          _change = i;
          _annotations = _annotations;
          _onChangedCommit(commit.sha);
        });
      },
    );
  }
}
