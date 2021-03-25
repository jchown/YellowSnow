class History {
  List<String> filenames = List.empty(growable: true);
  int currentPos = - 1;

  void push(String filename) {
    filenames.length = currentPos + 1;
    filenames.add(filename);
    currentPos = filenames.length - 1;
  }

  bool hasBack() {
    return currentPos > 0;
  }

  String getBack() {
    return filenames[currentPos - 1];
  }

  String back() {
    return filenames[--currentPos];
  }

  bool hasFwd() {
    return currentPos < filenames.length - 1;
  }

  String getFwd() {
    return filenames[currentPos + 1];
  }

  String fwd() {
    return filenames[++currentPos];
  }

  String getCurrent() {
    return filenames[currentPos];
  }
}