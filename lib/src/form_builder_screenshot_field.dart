import 'dart:typed_data';

import 'package:dcc_toolkit/dcc_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mopper/l10n/strings.dart';
import 'package:mopper/src/annotation_painter.dart';
import 'package:mopper/src/widgets/field_label.dart';

/// A [FormBuilderField] that displays a screenshot with annotation support.
///
/// The field value is the current screenshot bytes ([Uint8List]). When the user
/// annotates the screenshot the field value is updated to the annotated image.
///
/// While no screenshot is available (value is `null`), a loading placeholder is
/// shown.
class FormBuilderScreenshotField extends FormBuilderField<Uint8List?> {
  /// Creates a [FormBuilderScreenshotField] with the given [name].
  const FormBuilderScreenshotField({
    required super.name,
    super.key,
    super.validator,
    super.initialValue,
    super.enabled,
    this.decoration = const InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    ),
    this.onAnnotated,
    this.onAnnotatingChanged,
  }) : super(builder: _defaultBuilder);

  /// The decoration to show around the field.
  final InputDecoration decoration;

  /// Called when the user produces an annotated screenshot.
  final ValueChanged<Uint8List>? onAnnotated;

  /// Called when the annotation mode changes, allowing the parent to react
  /// (e.g., disable scrolling).
  final ValueChanged<bool>? onAnnotatingChanged;

  // Placeholder — actual build happens in createState's builder override.
  static Widget _defaultBuilder(FormFieldState<Uint8List?> field) {
    return const SizedBox.shrink();
  }

  @override
  FormBuilderFieldState<FormBuilderScreenshotField, Uint8List?> createState() =>
      _FormBuilderScreenshotFieldState();
}

class _FormBuilderScreenshotFieldState
    extends FormBuilderFieldState<FormBuilderScreenshotField, Uint8List?> {
  final _annotationKey = GlobalKey<AnnotationOverlayState>();
  bool _isAnnotating = false;

  @override
  void didUpdateWidget(covariant FormBuilderScreenshotField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent provides a new screenshot (e.g. async capture completes),
    // update the field value if it hasn't been annotated yet.
    // Deferred to post-frame to avoid calling setState during build.
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) didChange(widget.initialValue);
      });
    }
  }

  void _startAnnotating() {
    setState(() => _isAnnotating = true);
    widget.onAnnotatingChanged?.call(true);
  }

  Future<void> _finishAnnotating() async {
    await _annotationKey.currentState?.captureAnnotatedImage();
    if (mounted) {
      setState(() => _isAnnotating = false);
      widget.onAnnotatingChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenshot = value;

    return InputDecorator(
      decoration: widget.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          FieldLabel(label: context.mopperL10n.screenshotAttached),
          Margins.vertical8,

          // Screenshot area
          if (screenshot != null) ...[
            Margins.vertical8,
            if (_isAnnotating)
              // Annotation mode: drawing canvas + toolbar + Done button
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnnotationOverlay(
                    key: _annotationKey,
                    screenshot: widget.initialValue ?? screenshot,
                    onAnnotated: (bytes) {
                      didChange(bytes);
                      widget.onAnnotated?.call(bytes);
                    },
                  ),
                  Margins.vertical8,
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _finishAnnotating,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(context.mopperL10n.doneButton),
                      style: FilledButton.styleFrom(
                        padding: Paddings.horizontal16 + Paddings.vertical8,
                      ),
                    ),
                  ),
                ],
              )
            else
              // Static preview with "Annotate" button overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: Radiuses.circular12,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        borderRadius: Radiuses.circular12,
                      ),
                      padding: Paddings.all8,
                      child: Image.memory(
                        screenshot,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  // "Annotate" button — positioned bottom-right
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FilledButton.icon(
                      onPressed: _startAnnotating,
                      icon: const Icon(Icons.brush, size: 18),
                      label: Text(context.mopperL10n.annotateButton),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        elevation: 2,
                        padding: Paddings.horizontal16 + Paddings.vertical8,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ] else ...[
            // Screenshot loading placeholder
            Margins.vertical8,
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: Radiuses.circular12,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
