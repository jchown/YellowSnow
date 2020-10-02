import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:YellowSnow/annotations.dart';
import 'package:flutter/material.dart';

import 'theme.dart' as th;

class AnnotationMap extends WidgetToRenderBoxAdapter {
  AnnotationMap(Annotations annotions, th.Theme theme)
      : super(renderBox: new AnnotationMapRender(annotions, theme)) {
    (renderBox as AnnotationMapRender).widget = this;
  }
}

class AnnotationMapRender extends RenderBox {

  AnnotationMapRender(this.annotions, this.theme);

  Annotations annotions;
  th.Theme theme;
  AnnotationMap widget;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.smallest;
  }

  ui.Image image;
  Size creatingImage;

  void paint(PaintingContext context, Offset offset) {
    if (image == null ||
        image.width != size.width ||
        image.height != size.height) {
      if (creatingImage == null ||
          creatingImage.width != size.width ||
          creatingImage.height != size.height) {
        createImage();
      }
    }

    if (image == null) {
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.black), text: "Drawing...");
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(context.canvas, offset.translate(size.width / 2, 10));
    } else {
      var paint = Paint();
      context.canvas.drawImage(image, offset, paint);
    }
  }

  void callback(ui.Image result) {
    if (creatingImage.width == result.width &&
        creatingImage.height == result.height) {
      creatingImage = null;
      this.image = result;
      widget.renderBox.markNeedsPaint();
    }
  }

  void createImage() {
    creatingImage = Size(size.width, size.height);
    var w = size.width.toInt(), h = size.height.toInt();
    var pixels = Uint8List(w * h * 4);
    int i = 0;
    for (int y = 0; y < h; y++) {
      var line = annotions.lines[((y * annotions.lines.length) / h).floor()];
      var bgCol = theme.getBGColor(annotions.getLevel(line.timestamp));
      for (int x = 0; x < w; x++) {
        pixels[i++] = bgCol.red;
        pixels[i++] = bgCol.green;
        pixels[i++] = bgCol.blue;
        pixels[i++] = 0xff;
      }
    }

    ui.decodeImageFromPixels(pixels, size.width.toInt(), size.height.toInt(),
        ui.PixelFormat.rgba8888, callback);
  }
}
