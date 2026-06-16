import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mopper/src/models/stroke.dart';
import 'package:mopper/src/mopper_theme.dart';

/// Controller managing annotation state for the screenshot overlay.
///
/// Handles stroke management (add, undo), tool selection,
/// and color selection. The widget layer is responsible for rendering
/// strokes and capturing the final annotated image.
class AnnotationController extends ChangeNotifier {
  /// Creates an [AnnotationController] with default tool and color.
  AnnotationController();

  final List<Stroke> _strokes = [];
  Stroke? _currentStroke;
  AnnotationTool _activeTool = AnnotationTool.draw;
  Color _activeColor = MopperTheme.annotationRed;

  /// The available annotation colors.
  static const List<Color> colors = [
    MopperTheme.annotationRed,
    MopperTheme.annotationYellow,
    MopperTheme.annotationBlue,
  ];

  /// All completed strokes.
  UnmodifiableListView<Stroke> get strokes => UnmodifiableListView(_strokes);

  /// The stroke currently being drawn, or null if idle.
  Stroke? get currentStroke => _currentStroke;

  /// The currently active annotation tool.
  AnnotationTool get activeTool => _activeTool;

  /// The currently active stroke color.
  Color get activeColor => _activeColor;

  /// Whether any strokes exist that can be undone.
  bool get canUndo => _strokes.isNotEmpty;

  /// Called when a pan gesture starts. Begins a new stroke.
  void onPanStart(Offset position) {
    _currentStroke = Stroke(
      points: [position],
      color: _activeColor,
      tool: _activeTool,
    );
    notifyListeners();
  }

  /// Called when a pan gesture updates. Adds a point to the current stroke.
  void onPanUpdate(Offset position) {
    if (_currentStroke == null) return;
    _currentStroke!.points.add(position);
    notifyListeners();
  }

  /// Called when a pan gesture ends. Commits the current stroke.
  void onPanEnd() {
    if (_currentStroke == null) return;
    _strokes.add(_currentStroke!);
    _currentStroke = null;
    notifyListeners();
  }

  /// Removes the last stroke. Does nothing if there are no strokes.
  void undo() {
    if (_strokes.isEmpty) return;
    _strokes.removeLast();
    notifyListeners();
  }

  /// Sets the active annotation tool.
  void setTool(AnnotationTool tool) {
    if (_activeTool == tool) return;
    _activeTool = tool;
    notifyListeners();
  }

  /// Sets the active stroke color.
  void setColor(Color color) {
    if (_activeColor == color) return;
    _activeColor = color;
    notifyListeners();
  }
}
