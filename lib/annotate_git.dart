import 'dart:io';

import 'annotations.dart';
import 'annotations_file.dart';
import 'annotations_dir.dart';
import 'line_file.dart';
import 'line_dir.dart';
import 'workspace.dart';
import 'exec.dart';

class AnnotateGit {
  static const String program = "git";

  static Future<Annotations> getAnnotations(Workspace workspace, String filename) async {
    if (workspace.rootDir == filename) return getAnnotationsDir(workspace, filename);

    //  There's probably a better "is file" test...

    int lastSlash = filename.lastIndexOf(Workspace.dirChar);
    var dir = Directory(filename.substring(0, lastSlash));
    var entries = dir.listSync();
    var fse = (entries.firstWhere((f) => f.path == filename));
    if (fse is File)
      return getAnnotationsFile(workspace, filename);
    else
      return getAnnotationsDir(workspace, filename);
  }

  static Future<Annotations> getAnnotationsFile(Workspace workspace, String filename) async {
    var relFN = workspace.getRelativePath(filename);
    stdout.writeln("Filename: $filename -> $relFN");

    List<String> arguments = ["annotate", "-p", relFN];

    var command = Exec.run(program, arguments, workspace.rootDir, {"GIT_PAGER": "cat"});

    var source = await File(filename).readAsLines();
    var lines = new List<LineFile>();
    String editor = "";
    String editorEmail = "";
    String comment = "";
    int time = 0;

    var commandOutput = await command;
    for (var output in commandOutput) {
      if (output.length == 0) continue;

      if (output[0] != '\t') {
        int space = output.indexOf(' ');
        String right = output.substring(space + 1);
        if (output.startsWith("committer-time ")) {
          time = int.parse(right);
        } else if (output.startsWith("author ")) {
          editor = right;
        } else if (output.startsWith("author-mail ")) {
          editorEmail += right;
        } else if (output.startsWith("summary")) {
          comment = right;
        }
      } else {
        if (editorEmail.length > 0) {
          editor += " " + editorEmail;
          editorEmail = "";
        }

        lines.add(LineFile(
            editor,
            source[lines.length], //output.Substring(1), Can't use this, git has removed whitespace
            comment,
            time));
      }
    }

    return AnnotationsFile(lines);
  }

  static Future<Annotations> getAnnotationsDir(Workspace workspace, String directory) async {
    List<LineDir> files = new List<LineDir>();

    for (var dirEntry in await Directory(directory).list().toList()) {
      var edited = dirEntry.statSync().modified.millisecondsSinceEpoch;

      var filename = dirEntry.path.substring(dirEntry.path.lastIndexOf(Workspace.dirChar) + 1);

      //  Get the most recent edit

      List<String> arguments = [
        "log",
        "--pretty=format:ch:%H%nan:%an%nae:%ae%nat:%at%nsj:%sj",
        "-n",
        "1",
        "${dirEntry.path}"
      ];

      var command = await Exec.run(program, arguments, workspace.rootDir, null);

      String commitHash, authorName, authorEmail, subject, editor = "?";

      for (String output in command) {
        if (output.length == 0) continue;

        stdout.writeln("| $output");
        String key = output.substring(0, 3);
        String value = output.substring(3);
        if (key == "ch:")
          commitHash = value;
        else if (key == "ct:")
          edited = int.parse(value);
        else if (key == "an:")
          authorName = value;
        else if (key == "ae:")
          authorEmail = value;
        else if (key == "sj:") subject = value;
      }

      if (commitHash != null) {
        editor = authorName;
        if (authorEmail != null) editor += " <$authorEmail>";
      } else {
        edited = 0;
      }

      var absFilename = "$directory${Workspace.dirChar}$filename";
      files.add(LineDir(absFilename, editor, edited));
    }

    return new AnnotationsDir(files);
  }
}
