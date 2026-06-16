import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dcc_toolkit/dcc_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mopper/src/controllers/annotation_controller.dart';
import 'package:mopper/src/models/stroke.dart';

/// A widget that overlays on the screenshot preview and allows freehand
/// drawing, arrow annotations, undo, and color selection.
///
/// Call [AnnotationOverlayState.captureAnnotatedImage] to get the final
/// annotated screenshot as a PNG byte array.
class AnnotationOverlay extends StatefulWidget {
  /// Creates an [AnnotationOverlay] for the given [screenshot].
  const AnnotationOverlay({
    required this.screenshot,
    required this.onAnnotated,
    super.key,
  });

  /// The original screenshot to annotate.
  final Uint8List screenshot;

  /// Called when the user finishes annotating, with the final image bytes.
  /// This is triggered when the parent requests it via the GlobalKey.
  final ValueChanged<Uint8List> onAnnotated;

  @override
  State<AnnotationOverlay> createState() => AnnotationOverlayState();
}

/// State for [AnnotationOverlay] that manages capture via a controller.
class AnnotationOverlayState extends State<AnnotationOverlay> {
  final GlobalKey<State<StatefulWidget>> _repaintBoundaryKey = GlobalKey();
  late final AnnotationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnnotationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Captures the annotated screenshot and calls the widget's onAnnotated
  /// callback.
  Future<void> captureAnnotatedImage() async {
    final boundary = _repaintBoundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return;

    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      widget.onAnnotated(byteData.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Screenshot with annotation canvas
            ClipRRect(
              borderRadius: Radiuses.circular12,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  borderRadius: Radiuses.circular12,
                ),
                constraints: const BoxConstraints(maxHeight: 400),
                padding: Paddings.all8,
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: (details) =>
                            _controller.onPanStart(details.localPosition),
                        onPanUpdate: (details) =>
                            _controller.onPanUpdate(details.localPosition),
                        onPanEnd: (_) => _controller.onPanEnd(),
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          children: [
                            Image.memory(
                              widget.screenshot,
                              fit: BoxFit.contain,
                              width: constraints.maxWidth,
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _AnnotationPainter(
                                  strokes: _controller.strokes,
                                  currentStroke: _controller.currentStroke,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Margins.vertical8,
            // Toolbar
            Container(
              padding: Paddings.all8,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: Radiuses.circular8,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  _ToolButton(
                    icon: Icons.edit,
                    isActive: _controller.activeTool == AnnotationTool.draw,
                    onPressed: () => _controller.setTool(AnnotationTool.draw),
                  ),
                  Margins.horizontal4,
                  _ToolButton(
                    icon: Icons.trending_flat,
                    isActive: _controller.activeTool == AnnotationTool.arrow,
                    onPressed: () => _controller.setTool(AnnotationTool.arrow),
                  ),
                  Margins.horizontal4,
                  _ToolButton(
                    icon: Icons.undo,
                    isActive: false,
                    onPressed: _controller.canUndo ? _controller.undo : null,
                  ),
                  const Spacer(),
                  for (final color in AnnotationController.colors) ...[
                    _ColorDot(
                      color: color,
                      isActive: _controller.activeColor == color,
                      onPressed: () => _controller.setColor(color),
                    ),
                    if (color != AnnotationController.colors.last)
                      Margins.horizontal4,
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A small square tool button in the annotation toolbar.
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.isActive,
    this.onPressed,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: isActive ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? colorScheme.onPrimary
                : onPressed != null
                ? colorScheme.onSurface
                : colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// A small circular color selector dot in the annotation toolbar.
class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.isActive,
    required this.onPressed,
  });

  final Color color;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter that renders all strokes and the current in-progress stroke.
class _AnnotationPainter extends CustomPainter {
  _AnnotationPainter({required this.strokes, this.currentStroke});

  final List<Stroke> strokes;
  final Stroke? currentStroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _paintStroke(canvas, currentStroke!);
    }
  }

  void _paintStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (stroke.tool) {
      case AnnotationTool.draw:
        _paintFreehand(canvas, stroke.points, paint);
      case AnnotationTool.arrow:
        _paintArrow(canvas, stroke.points, paint);
    }
  }

  void _paintFreehand(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) {
      canvas.drawCircle(points.first, paint.strokeWidth / 2, paint);
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _paintArrow(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;

    final start = points.first;
    final end = points.last;

    // Draw the line
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    final angle = (end - start).direction;
    const arrowLength = 12.0;
    const arrowAngle = 0.5; // radians (~30 degrees)

    final p1 = Offset(
      end.dx - arrowLength * math.cos(angle - arrowAngle),
      end.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    final p2 = Offset(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..moveTo(end.dx, end.dy)
      ..lineTo(p2.dx, p2.dy);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) => true;
}
