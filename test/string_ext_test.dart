import 'package:flutter_test/flutter_test.dart';
import 'package:yellow_snow/string_ext.dart';

void main() {
  test('String repeat works', () {
    expect("*".repeat(3), "***");
    expect("12".repeat(1), "12");
    expect("---".repeat(0), "");
  });
}