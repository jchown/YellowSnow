extension StringExt on String {

  String replaceTabs(int numSpaces) {
    return this.replaceAll("\t", " ".repeat(numSpaces));
  }

  String repeat(int numTimes) {
    var buffer = new StringBuffer();
    for (int i=0; i<numTimes; i++)
      buffer.write(this);
    return buffer.toString();
  }

}