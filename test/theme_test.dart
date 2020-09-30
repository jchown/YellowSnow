import 'package:YellowSnow/theme.dart';
import 'package:YellowSnow/themes.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PurpleStain colour gradient works', () {
    var ps = Themes.purpleStain;
    expect(ps.getBGColor(0), equals(Color.fromARGB(0xff, 30, 30, 30)));
    expect(ps.getBGColor(255), equals(Color.fromARGB(0xff, 87, 38, 128)));
  });
}