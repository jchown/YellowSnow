import 'package:YellowSnow/annotate_git.dart';
import 'package:YellowSnow/line_file.dart';
import 'package:YellowSnow/workspace.dart';

import 'annotations.dart';

/// Base class of an annotated file, usually using a VCS to provide per-line
/// timestamps etc.

class AnnotationsFile extends Annotations {
  final List<Commit> changes;
  final Workspace _workspace;
  final String _filename;
  final AnnotationsFile _parent;
  final Map<String, AnnotationsFile> _children = Map();

  AnnotationsFile(this._workspace, this._filename, this._parent, this.changes, List<LineFile> lines) : super(lines);

  @override
  String getSummary(int line) {
    throw UnimplementedError();
  }

  List<Commit> getChanges() {
    return changes;
  }

  Future<AnnotationsFile> getChildAnnotations(String sha) async {
    if (_parent != null) return _parent.getChildAnnotations(sha);

    if (_children.containsKey(sha)) return _children[sha];

    var childAnnotations = AnnotateGit.getAnnotationsFile(this, _workspace, _filename, sha);
    childAnnotations.then((result) => _children[sha] = result);

    return childAnnotations;
  }

  AnnotationsFile getRoot() {
    return (_parent == null) ? this : _parent.getRoot();
  }
}
