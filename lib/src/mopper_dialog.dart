import 'dart:typed_data';

import 'package:dcc_toolkit/dcc_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:mopper/l10n/strings.dart';
import 'package:mopper/src/controllers/mopper_submission_controller.dart';
import 'package:mopper/src/integrations/mopper_integration.dart';
import 'package:mopper/src/models/mopper_data.dart';
import 'package:mopper/src/mopper_form.dart';
import 'package:mopper/src/mopper_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A full-screen overlay that displays the mopper form and handles submission.
///
/// Applies the [MopperTheme] to ensure consistent styling regardless of the
/// host application's theme. Dispatches submissions to all configured
/// [MopperIntegration]s in parallel via [MopperSubmissionController].
class MopperDialog extends StatefulWidget {
  /// Creates a [MopperDialog] with required close callback and integrations.
  const MopperDialog({
    required this.onClose,
    required this.integrations,
    this.screenshot,
    this.packageInfo,
    super.key,
  });

  /// The captured screenshot bytes to display and annotate.
  final Uint8List? screenshot;

  /// Called when the dialog is closed (discard or after successful submit).
  final VoidCallback onClose;

  /// The list of integrations to submit feedback to.
  final List<MopperIntegration> integrations;

  /// Optional pre-loaded package info to avoid redundant platform calls.
  final PackageInfo? packageInfo;

  @override
  State<MopperDialog> createState() => _MopperDialogState();
}

class _MopperDialogState extends State<MopperDialog> {
  late final MopperSubmissionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MopperSubmissionController(integrations: widget.integrations);
    _controller.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStatusChanged)
      ..dispose();
    super.dispose();
  }

  void _onStatusChanged() {
    if (!mounted) return;

    switch (_controller.status) {
      case SubmissionStatus.success:
        widget.onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.mopperL10n.feedbackSubmittedSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case SubmissionStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.mopperL10n.feedbackSubmittedError(
                _controller.errors.join(', '),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      case SubmissionStatus.idle:
      case SubmissionStatus.submitting:
        break;
    }
  }

  Future<void> _handleSubmit(MopperData data) async {
    final screenshot =
        _controller.annotatedScreenshot ?? widget.screenshot ?? Uint8List(0);

    await _controller.submit(data, screenshot);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MopperTheme.light,
      child: Builder(
        builder: (context) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Stack(
                  children: [
                    MopperForm(
                      screenshot: widget.screenshot,
                      onSubmit: _handleSubmit,
                      onDiscard: widget.onClose,
                      onAnnotated: (bytes) =>
                          _controller.annotatedScreenshot = bytes,
                      packageInfo: widget.packageInfo,
                    ),
                    if (_controller.status == SubmissionStatus.submitting)
                      ColoredBox(
                        color: Colors.black26,
                        child: Center(
                          child: Card(
                            child: Padding(
                              padding: Paddings.all24,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  Margins.vertical16,
                                  Text(context.mopperL10n.submittingFeedback),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
