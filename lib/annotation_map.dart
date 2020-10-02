import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as wdgt;
import 'package:image/image.dart' as img;

class AnnotationMap extends WidgetToRenderBoxAdapter {
  AnnotationMap() : super(renderBox: new AnnotationMapRender()) {
    (renderBox as AnnotationMapRender).widget = this;
  }
}

class AnnotationMapRender extends RenderBox {
  @override
  bool get sizedByParent => true;

  AnnotationMap widget;

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
      for (int x = 0; x < w; x++) {
        pixels[i++] = 0xff;
        pixels[i++] = 0x0;
        pixels[i++] = 0x0;
        pixels[i++] = 0xff;
      }
    }

    ui.decodeImageFromPixels(pixels, size.width.toInt(), size.height.toInt(),
        ui.PixelFormat.rgba8888, callback);
  }
}
