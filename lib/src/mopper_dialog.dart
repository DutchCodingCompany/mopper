import 'dart:typed_data';

import 'package:dcc_toolkit/dcc_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:mopper/l10n/strings.dart';
import 'package:mopper/src/integrations/mopper_integration.dart';
import 'package:mopper/src/models/mopper_data.dart';
import 'package:mopper/src/mopper_form.dart';
import 'package:mopper/src/mopper_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A full-screen overlay that displays the mopper form and handles submission.
///
/// Applies the [MopperTheme] to ensure consistent styling regardless of the
/// host application's theme. Dispatches submissions to all configured
/// [MopperIntegration]s in parallel.
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
  bool _isSubmitting = false;
  Uint8List? _annotatedScreenshot;

  Future<void> _handleSubmit(MopperData data) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final submission = MopperSubmission(
      data: data,
      screenshot: _annotatedScreenshot ?? widget.screenshot ?? Uint8List(0),
    );

    final errors = <String>[];

    // Run all integrations in parallel
    await Future.wait(
      widget.integrations.map((integration) async {
        try {
          await integration.submit(submission);
        } on Exception catch (e) {
          errors.add('${integration.name}: $e');
        }
      }),
    );

    if (!mounted) return;

    if (errors.isEmpty) {
      widget.onClose();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.mopperL10n.feedbackSubmittedSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.mopperL10n.feedbackSubmittedError(errors.join(', ')),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MopperTheme.light,
      child: Builder(
        builder: (context) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
                MopperForm(
                  screenshot: widget.screenshot,
                  onSubmit: _handleSubmit,
                  onDiscard: widget.onClose,
                  onAnnotated: (bytes) => _annotatedScreenshot = bytes,
                  packageInfo: widget.packageInfo,
                ),
                if (_isSubmitting)
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
            ),
          );
        },
      ),
    );
  }
}
