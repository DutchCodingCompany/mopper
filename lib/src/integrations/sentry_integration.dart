import 'dart:async';

import 'package:mopper/src/integrations/mopper_integration.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry Mopper integration.
///
/// Submits mopper via Sentry's `captureFeedback` API. The screenshot is
/// included as an attachment on the feedback event.
class SentryFeedbackIntegration implements MopperIntegration {
  @override
  Future<void> submit(MopperSubmission submission) async {
    final description = switch (submission.data.title) {
      null => submission.data.description,
      final title => '$title\n\n${submission.data.description}',
    };

    final feedback = SentryFeedback(
      message: description,
      name: submission.data.userName,
    );

    await Sentry.captureFeedback(
      feedback,
      withScope: (scope) {
        unawaited(
          scope.setTag('mopper_category', submission.data.category ?? 'none'),
        );
        if (submission.screenshot.isNotEmpty) {
          scope.addAttachment(
            SentryAttachment.fromUint8List(
              submission.screenshot,
              'screenshot.png',
              contentType: 'image/png',
            ),
          );
        }
      },
    );
  }
}
