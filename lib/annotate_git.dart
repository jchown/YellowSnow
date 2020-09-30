import 'dart:io';

import 'package:YellowSnow/annotations_file.dart';

import 'exec.dart';
import 'line_file.dart';
import 'workspace.dart';
import 'annotations.dart';

class AnnotateGit {
  static const String program = "git";

  static Future<Annotations> getAnnotations(
      Workspace workspace, String filename) async {
    var relFN = workspace.getRelativePath(filename);
    stdout.writeln("Filename: $filename -> $relFN");

    List<String> arguments = ["annotate", "-p", relFN];

    var command =
        Exec.run(program, arguments, workspace.rootDir, {"GIT_PAGER": "cat"});

    var source = await File(filename).readAsLines();
    var lines = new List<LineFile>();
    String editor = "", editorEmail = "";
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
        }
      } else {
        if (editorEmail.length > 0) {
          editor += " " + editorEmail;
          editorEmail = "";
        }

        lines.add(LineFile(
            editor,
            source[lines.length],
            //output.Substring(1), Can't use this, git has removed whitespace
            time));
      }
    }

    return AnnotationsFile(lines);
  }

/*
override public Annotations GetAnnotationsDir(string directory)
{
  List<FSEntry> files = new List<FSEntry>();

  foreach (var file in Directory.EnumerateFileSystemEntries(directory))
  {
  FileAttributes attr = File.GetAttributes(file);

  string editor = File.GetAccessControl(file).GetOwner(typeof(System.Security.Principal.NTAccount)).ToString();
  long edited = Epoch.ToLong(File.GetLastAccessTime(file));
  string commitHash = null, authorName = null, authorEmail = null, subject = null;

  //  Get the most recent edit

  Strings arguments = new Strings();
  arguments.Add("log");
  arguments.Add("--pretty=format:ch:%H%nan:%an%nae:%ae%nat:%at%nsj:%sj");
  arguments.Add("-n");
  arguments.Add("1");
  arguments.Add(file.GetFileName());

  Command command = new Command(program, directory, arguments);

  foreach (string output in command.GetOutput())
  {
  string key = output.Substring(0, 3);
  string value = output.Substring(3);
  if (key == "ch:")
  commitHash = value;
  else if (key == "ct:")
  edited = long.Parse(value);
  else if (key == "an:")
  authorName = value;
  else if (key == "ae:")
  authorEmail = value;
  else if (key == "sj:")
  subject = value;
  }

  if (commitHash != null)
  {
  editor = authorName;
  if (authorEmail != null)
  editor += " <" + authorEmail + ">";
  }

  files.Add(new FSEntry
  {
  editor = editor,
  name = file,
  modified = edited
  });
  }

  return new AnnotationsFS(files);
}

 */
}
