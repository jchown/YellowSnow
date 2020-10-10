import 'package:YellowSnow/color_scheme.dart';
import 'package:YellowSnow/color_schemes.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PurpleStain colour gradient works', () {
    var ps = ColorSchemes.purpleStain;
    expect(ps.getBGColor(0), equals(Color.fromARGB(0xff, 30, 30, 30)));
    expect(ps.getBGColor(255), equals(Color.fromARGB(0xff, 87, 38, 128)));
  });
}