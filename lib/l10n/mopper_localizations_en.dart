// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mopper_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MopperLocalizationsEn extends MopperLocalizations {
  MopperLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get feedbackButtonLabel => 'Feedback';

  @override
  String get submitFeedbackTitle => 'Submit Feedback';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint =>
      'Please describe the steps to reproduce or your specific suggestion...';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryUiUx => 'UI/UX';

  @override
  String get categoryBug => 'Bug';

  @override
  String get categoryPerformance => 'Performance';

  @override
  String get categoryFeature => 'Feature';

  @override
  String get yourNameLabel => 'Your Name (Optional)';

  @override
  String get yourNameHint => 'e.g. Alex Chen';

  @override
  String get feedbackTitleLabel => 'Feedback Title (Optional)';

  @override
  String get feedbackTitleHint => 'Brief summary of the issue';

  @override
  String get discardButton => 'Discard';

  @override
  String get submitButton => 'Submit Feedback';

  @override
  String get screenshotAttached => 'Screenshot attached';

  @override
  String get annotateButton => 'Annotate';

  @override
  String get doneButton => 'Done';

  @override
  String get requiredBadge => 'REQUIRED';

  @override
  String get systemDiagnosticsTitle => 'System Diagnostics';

  @override
  String get feedbackSubmittedSuccess => 'Feedback submitted successfully.';

  @override
  String feedbackSubmittedError(String errors) {
    return 'Failed: $errors';
  }

  @override
  String get submittingFeedback => 'Submitting feedback...';
}
