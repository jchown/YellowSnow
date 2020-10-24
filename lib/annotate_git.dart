import 'dart:io';

import 'annotations.dart';
import 'annotations_file.dart';
import 'annotations_dir.dart';
import 'line_file.dart';
import 'line_dir.dart';
import 'workspace.dart';
import 'exec.dart';

class Commit {
  String sha;
  int timestamp;
  String comment = "";
  String editor = "";
  String editorEmail = "";
}

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
      return getAnnotationsFile(null, workspace, filename, null);
    else
      return getAnnotationsDir(workspace, filename);
  }

  static Future<AnnotationsFile> getAnnotationsFile(Annotations parent, Workspace workspace, String filename, String sha) async {
    var relFN = workspace.getRelativePath(filename);

    List<String> arguments = ["annotate", "-p", relFN];
    if (sha != null)
      arguments.add(sha);

    var command = Exec.run(program, arguments, workspace.rootDir, {"GIT_PAGER": "cat"});

    var source = await File(filename).readAsLines();
    var lines = new List<LineFile>();
    Map<String, Commit> commits = Map();

    var firstLine = true;
    var currentCommit = Commit();
    var commandOutput = await command;
    for (var output in commandOutput) {
      if (output.length == 0) continue;

      if (output[0] != '\t') {
        int space = output.indexOf(' ');
        String left = output.substring(0, space);
        String right = output.substring(space + 1);

        //  First line of info is always the hash with line numbers

        if (firstLine) {
          String sha = left;
          if (!commits.containsKey(sha)) {
            currentCommit.sha = sha;
            commits[sha] = currentCommit;
          } else {
            currentCommit = commits[sha];
          }

          firstLine = false;
        }

        switch (left) {
          case "committer-time":
            currentCommit.timestamp = int.parse(right);
            break;
          case "author":
            currentCommit.editor = right;
            break;
          case "author-mail":
            currentCommit.editorEmail += right;
            break;
          case "summary":
            currentCommit.comment = right;
            break;
          default:
            // stdout.writeln("? $output");
            break;
        }
      } else {
        var editor = currentCommit.editor;
        if (currentCommit.editorEmail.length > 0) {
          editor += " " + currentCommit.editorEmail;
        }

        lines.add(LineFile(
            editor,
            source[lines.length], //output.Substring(1), Can't use this, git has removed whitespace
            currentCommit.comment,
            currentCommit.timestamp));

        firstLine = true;
        currentCommit = Commit();
      }
    }

    var changes = commits.values.toList();
    changes.sort((a, b) => a.timestamp - b.timestamp);

    return AnnotationsFile(workspace, filename, parent, changes, lines);
  }

  static Future<Annotations> getAnnotationsDir(Workspace workspace, String directory) async {
    List<Future<LineDir>> files = new List<Future<LineDir>>();

    for (var dirEntry in await Directory(directory).list().toList()) {
      files.add(getAnnotationDirEntry(workspace, directory, dirEntry));
    }

    return new AnnotationsDir(await Future.wait(files));
  }

  static Future<LineDir> getAnnotationDirEntry(Workspace workspace, String directory, FileSystemEntity dirEntry) async {
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
    return LineDir(absFilename, editor, edited);
  }
}
