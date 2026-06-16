import 'dart:ui';

/// The type of annotation tool currently selected.
enum AnnotationTool {
  /// Freehand drawing tool.
  draw,

  /// Arrow annotation tool.
  arrow,
}

/// A single annotation stroke drawn by the user.
class Stroke {
  /// Creates a [Stroke] with the given [points], [color], and [tool].
  Stroke({required this.points, required this.color, required this.tool});

  /// The list of points that make up this stroke.
  final List<Offset> points;

  /// The color of this stroke.
  final Color color;

  /// The tool used to draw this stroke.
  final AnnotationTool tool;
}
