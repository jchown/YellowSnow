import 'annotations.dart';

/// Base class of an annotated file, usually using a VCS to provide per-line
/// timestamps etc.

class AnnotationsFile extends Annotations {
  AnnotationsFile(List<Line> lines) : super(lines);

  @override
  String getSummary(int line) {
    throw UnimplementedError();
  }
}