import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mopper/src/integrations/mopper_integration.dart';
import 'package:mopper/src/models/mopper_data.dart';

/// The current status of a feedback submission.
enum SubmissionStatus {
  /// No submission in progress.
  idle,

  /// A submission is currently being sent to integrations.
  submitting,

  /// All integrations completed successfully.
  success,

  /// One or more integrations failed.
  error,
}

/// Controller managing the feedback submission lifecycle.
///
/// Orchestrates parallel dispatch to all configured [MopperIntegration]s,
/// collects errors, and exposes status for the UI to react to.
class MopperSubmissionController extends ChangeNotifier {
  /// Creates a [MopperSubmissionController] with the given [integrations].
  MopperSubmissionController({required this.integrations});

  /// The list of integrations to submit feedback to.
  final List<MopperIntegration> integrations;

  SubmissionStatus _status = SubmissionStatus.idle;
  final List<String> _errors = [];

  /// The annotated screenshot bytes, updated by the annotation overlay.
  Uint8List? annotatedScreenshot;

  /// The current submission status.
  SubmissionStatus get status => _status;

  /// The list of error messages from failed integrations.
  UnmodifiableListView<String> get errors => UnmodifiableListView(_errors);

  /// Submits feedback to all configured integrations in parallel.
  ///
  /// Transitions status from [SubmissionStatus.idle] to
  /// [SubmissionStatus.submitting], then to [SubmissionStatus.success]
  /// or [SubmissionStatus.error] depending on results.
  Future<void> submit(MopperData data, Uint8List screenshot) async {
    if (_status == SubmissionStatus.submitting) return;

    _status = SubmissionStatus.submitting;
    _errors.clear();
    notifyListeners();

    final submission = MopperSubmission(data: data, screenshot: screenshot);

    await Future.wait(
      integrations.map((integration) async {
        try {
          await integration.submit(submission);
        } on Exception catch (e) {
          _errors.add('$e');
        }
      }),
    );

    _status = _errors.isEmpty
        ? SubmissionStatus.success
        : SubmissionStatus.error;
    notifyListeners();
  }

  /// Resets the controller to [SubmissionStatus.idle].
  void reset() {
    _status = SubmissionStatus.idle;
    _errors.clear();
    annotatedScreenshot = null;
    notifyListeners();
  }
}
