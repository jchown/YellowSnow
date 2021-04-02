import 'package:flutter/widgets.dart';

import 'annotations.dart';
import 'render_style.dart';

/// Base class of an annotated line
abstract class Line {
  int timestamp = 0;

  Widget getWidget(Annotations annotations, RenderStyle renderStyle);

  String getFilename();
}
