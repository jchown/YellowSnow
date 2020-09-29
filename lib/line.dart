import 'package:YellowSnow/theme.dart';
import 'package:flutter/widgets.dart';

import 'annotations.dart';

/// Base class of an annotated line
abstract class Line {
  int timestamp;

  Widget getWidget(Annotations annotations, Theme theme);
}
