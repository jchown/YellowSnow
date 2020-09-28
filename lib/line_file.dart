import 'package:YellowSnow/annotations.dart';

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
  String get text => source;
}