class AnnotaterGit : Annotater
{
const string program = "git";

override public bool IsInWorkspace(string filename)
{
  return Workspace.FindDir(filename, ".git", ref workspaceRoot);
}

override public Annotations GetAnnotationsFile(string filename)
{
  string dir = filename.GetFilePath();
  Strings arguments = new Strings();
  arguments.Add("annotate");
  arguments.Add("-p");
  arguments.Add(filename.GetFileName());

  var command = new Command(program, dir, arguments, "GIT_PAGER=cat");

  var source = Strings.Load(filename);
  var times = new Dictionary<long, bool>();
  var lines = new List<Line>();
  lines.Capacity = source.Count;
  string editor = "???", editorEmail = "";
  long time = 0;

  foreach (string output in command.GetOutput())
  {
  if (output == null || output.Length == 0)
  continue;

  if (output[0] != '\t')
  {
  int space = output.IndexOf(' ');
  string right = output.Substring(space + 1);
  if (output.StartsWith("committer-time "))
  {
  time = long.Parse(right);
  }
  else if (output.StartsWith("author "))
  {
  editor = right;
  }
  else if (output.StartsWith("author-mail "))
  {
  editorEmail += right;
  }
  }
  else
  {
  if (editorEmail.Length > 0)
  {
  editor += " " + editorEmail;
  editorEmail = "";
  }

  lines.Add(new Line
  {
  editor = editor,
  line = source[lines.Count],//output.Substring(1), Can't use this, git has removed whitespace
  time = time
  });
  }
  }

  return new AnnotationsVCS(lines);
}

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
}
