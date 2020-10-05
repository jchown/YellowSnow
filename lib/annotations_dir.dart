import 'annotations.dart';
import 'line_dir.dart';

/// Base class of an annotated directory, using a VCS to provide per-file
/// timestamps etc.

class AnnotationsDir extends Annotations {
  AnnotationsDir(List<LineDir> lines) : super(lines);

  @override
  String getSummary(int line) {
    throw UnimplementedError();
  }
}