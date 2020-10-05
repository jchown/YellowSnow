import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:YellowSnow/annotations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme.dart' as th;

/// A widget to drag the "map" of colours

class AnnotationMap extends WidgetToRenderBoxAdapter {
  AnnotationMap(Annotations annotations, th.Theme theme) : super(renderBox: new RenderedMap(annotations, theme)) {
    (renderBox as RenderedMap).widget = this;
  }
}

/// A widget to highlight an area of the map

class AnnotationZone extends WidgetToRenderBoxAdapter {
  RenderedZone get renderedZone => renderBox as RenderedZone;

  AnnotationZone(Annotations annotations, th.Theme theme) : super(renderBox: new RenderedZone(annotations, theme)) {
    renderedZone.widget = this;
  }

  void update(double totalHeight, double zoneStart, double zoneHeight) {
    renderedZone.update(totalHeight, zoneStart, zoneHeight);
  }
}

/// Renders & caches a map of the file

class RenderedMap extends RenderBox {
  RenderedMap(this.annotations, this.theme);

  Annotations annotations;
  th.Theme theme;
  AnnotationMap widget;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.smallest;
  }

  ui.Image image;
  MapRenderer rendering;

  void paint(PaintingContext context, Offset offset) {
    if (annotations.lines.length == 0) {
      //  No annotations, no map
      paintEmpty(context, offset);
      return;
    }

    var w = size.width.floor();
    var h = size.height.floor();
    if (image == null || image.width != w || image.height != h) {
      if (rendering == null || rendering.w != w || rendering.h != h) {
        rendering = MapRenderer(this, w, h);
      }
    }

    if (image == null) {
      TextSpan span = new TextSpan(style: new TextStyle(color: Colors.black), text: "Drawing...");
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(context.canvas, offset.translate(size.width / 2, 10));
    } else {
      var paint = Paint();
      context.canvas.drawImage(image, offset, paint);
    }
  }

  void callback(ui.Image result) {
    this.image = result;
    widget.renderBox.markNeedsPaint();
  }

  void paintEmpty(PaintingContext context, Offset offset) {
    image = null;
    rendering = null;
    var paint = Paint();
    paint.color = theme?.bgOld ?? Colors.white;
    var rect = Rect.fromPoints(offset.translate(0, 0), offset.translate(size.width, size.height));
    context.canvas.drawRect(rect, paint);
  }
}

/// Renders a map in software, passing the result back to RenderedMap (if still applicable)

class MapRenderer {
  RenderedMap render;
  int w, h;

  MapRenderer(this.render, this.w, this.h) {
    stdout.writeln("Rendering map $w x $h");

    var annotations = render.annotations;
    var theme = render.theme;
    var pixels = Uint8List(w * h * 4);

    int i = 0;
    for (int y = 0; y < h; y++) {
      var line = annotations.lines[((y * annotations.lines.length) / h).floor()];
      var bgCol = theme.getBGColor(annotations.getLevel(line.timestamp));
      for (int x = 0; x < w; x++) {
        pixels[i++] = bgCol.red;
        pixels[i++] = bgCol.green;
        pixels[i++] = bgCol.blue;
        pixels[i++] = 0xff;
      }
    }

    ui.decodeImageFromPixels(pixels, w, h, ui.PixelFormat.rgba8888, callback);
  }

  void callback(ui.Image result) {
    //  Ensure we only show the most recent rendering
    if (render.rendering == this) {
      render.callback(result);
    }
  }
}

/// Draw a rectangle showing the area of the map that is in view

class RenderedZone extends RenderBox {
  RenderedZone(this.annotations, this.theme);

  Annotations annotations;
  th.Theme theme;
  AnnotationZone widget;

  var zoneStart;
  var zoneHeight;
  var totalHeight = 0.0;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.smallest;
  }

  void paint(PaintingContext context, Offset offset) {
    if (widget != null && totalHeight > 0) {
      var paint = Paint();
      paint.color = theme?.fgOld ?? Colors.black;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      paint.strokeJoin = StrokeJoin.round;
      paint.strokeCap = StrokeCap.round;
      var top = (zoneStart * size.height) / totalHeight;
      var bottom = ((zoneStart + zoneHeight) * size.height) / totalHeight;
      var rect = Rect.fromPoints(offset.translate(2, top), offset.translate(size.width - 2, bottom));
      context.canvas.drawRect(rect, paint);
    }
  }

  void update(double totalHeight, double zoneStart, double zoneHeight) {
    if (this.zoneStart != zoneStart || this.zoneHeight != zoneHeight || this.totalHeight != totalHeight) {
      this.zoneStart = zoneStart;
      this.zoneHeight = zoneHeight;
      this.totalHeight = totalHeight;
      markNeedsPaint();
    }
  }
}
