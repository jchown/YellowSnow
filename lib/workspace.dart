import 'dart:io';

class Workspace {
  static const dirChar = '\\';

  /// The base directory of the

  String rootDir;

  Workspace(String rootDir) {
    this.rootDir = rootDir + dirChar;
  }

  /// Find a workspace root by searching for a VCS

  static Future<Workspace> find(String filename) async {
    return findDir(filename.substring(0, filename.lastIndexOf(dirChar)), ".git");
  }

  /// Find a workspace by searching for the given subdirectory (e.g. ".git")
  /// starting from the base directory and working upwards

  static Future<Workspace> findDir(String baseDir, String dirName) async {
    var directory = "$baseDir$dirChar$dirName";

    if (await Directory(directory).exists()) {
      return Workspace(baseDir);
    }

    int slash = baseDir.lastIndexOf(dirChar);
    if (slash > 0) {
      return findDir(baseDir.substring(0, slash), dirName);
    }

    return null;
  }

  /// Return a workspace relative path

  String getRelativePath(String absolutePath) {
    if (!absolutePath.startsWith(rootDir))
      throw new Exception("Expected $absolutePath to start with $rootDir");

    return absolutePath.substring(rootDir.length);
  }

  static Workspace pending() {
    return new Workspace("?");
  }
}
