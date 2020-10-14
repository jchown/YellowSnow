import 'package:YellowSnow/annotations_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Timeline extends StatefulWidget {
  Timeline(this.annotations, {Key key}) : super(key: key);

  final AnnotationsFile annotations;

  @override
  _TimelineState createState() => _TimelineState(annotations, annotations.getChanges().length - 1);
}

class _TimelineState extends State<Timeline> {
  AnnotationsFile _annotations;
  int _change;

  _TimelineState(this._annotations, this._change);

  @override
  Widget build(BuildContext context) {
    if (_annotations.getChanges().length < 2)
      return Slider(value: 0, min: 0, max: 0);

    var commit = _annotations.getChanges()[_change];
    var dateFormat = DateFormat("yyyy.MM.dd HH:mm:ss");

    return Slider(
      value: _change.toDouble(),
      min: 0,
      max: (_annotations.getChanges().length - 1).toDouble(),
      divisions: _annotations.getChanges().length,
      label: "SHA: ${commit.sha}\n${dateFormat.format(new DateTime.fromMillisecondsSinceEpoch(commit.timestamp * 1000))}\n\n${commit.editor} ${commit.editorEmail}\n${commit.comment}",
      onChanged: (double value) {
        setState(() {
          _annotations = _annotations;
          _change = value.toInt();
        });
      },
    );
  }
}
