// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mopper_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class MopperLocalizationsNl extends MopperLocalizations {
  MopperLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get feedbackButtonLabel => 'Feedback';

  @override
  String get submitFeedbackTitle => 'Feedback verzenden';

  @override
  String get descriptionLabel => 'Beschrijving';

  @override
  String get descriptionHint =>
      'Beschrijf de stappen om te reproduceren of uw specifieke suggestie...';

  @override
  String get descriptionRequired => 'Beschrijving is verplicht';

  @override
  String get categoryLabel => 'Categorie';

  @override
  String get categoryUiUx => 'UI/UX';

  @override
  String get categoryBug => 'Bug';

  @override
  String get categoryPerformance => 'Prestaties';

  @override
  String get categoryFeature => 'Functie';

  @override
  String get yourNameLabel => 'Uw naam (optioneel)';

  @override
  String get yourNameHint => 'bijv. Jan Jansen';

  @override
  String get feedbackTitleLabel => 'Feedbacktitel (optioneel)';

  @override
  String get feedbackTitleHint => 'Korte samenvatting van het probleem';

  @override
  String get discardButton => 'Verwijderen';

  @override
  String get submitButton => 'Feedback verzenden';

  @override
  String get screenshotAttached => 'Schermafbeelding bijgevoegd';

  @override
  String get annotateButton => 'Markeren';

  @override
  String get doneButton => 'Klaar';

  @override
  String get requiredBadge => 'VERPLICHT';

  @override
  String get systemDiagnosticsTitle => 'Systeemdiagnostiek';

  @override
  String get feedbackSubmittedSuccess => 'Feedback succesvol verzonden.';

  @override
  String feedbackSubmittedError(String errors) {
    return 'Mislukt: $errors';
  }

  @override
  String get submittingFeedback => 'Feedback verzenden...';
}
