import 'package:YellowSnow/annotate_git.dart';
import 'package:YellowSnow/line_file.dart';

import 'annotations.dart';

/// Base class of an annotated file, usually using a VCS to provide per-line
/// timestamps etc.

class AnnotationsFile extends Annotations {
  List<Commit> changes;

  AnnotationsFile(this.changes, List<LineFile> lines) : super(lines);

  @override
  String getSummary(int line) {
    throw UnimplementedError();
  }

  List<Commit> getChanges() {
    return changes;
  }
}
