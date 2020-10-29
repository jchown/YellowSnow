import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Exec {
  static Future<List<String>> run(String program, List<String> arguments, String workingDirectory, Map<String,String> environment) async {

//    stdout.write("> $program ${arguments.join(' ')}\n");

    var process = await Process.start(program, arguments,
        workingDirectory: workingDirectory,
        environment: environment ?? Map()
    );

    final List<int> output = <int>[];

    final Completer<int> completeOut = Completer<int>();
    process.stdout.listen((List<int> event) {
      output.addAll(event);
    }, onDone: () async => completeOut.complete(process.exitCode));

    final Completer<int> completeErr = Completer<int>();
    process.stderr.listen((List<int> event) {
      output.addAll(event);
    }, onDone: () async => completeErr.complete(process.exitCode));

    await completeErr.future;
    final int exitCode = await completeOut.future;

    if (exitCode != 0) {
      stderr.write('Running "$program ${arguments.join(' ')}" failed with status code $exitCode:\n${Utf8Decoder().convert(output)}\n');
    }

    var decoded = Utf8Decoder().convert(output);
    return LineSplitter.split(decoded).toList();
  }
}