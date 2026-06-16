import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'mopper_localizations_en.dart';
import 'mopper_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MopperLocalizations
/// returned by `MopperLocalizations.of(context)`.
///
/// Applications need to include `MopperLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/mopper_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MopperLocalizations.localizationsDelegates,
///   supportedLocales: MopperLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the MopperLocalizations.supportedLocales
/// property.
abstract class MopperLocalizations {
  MopperLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MopperLocalizations? of(BuildContext context) {
    return Localizations.of<MopperLocalizations>(context, MopperLocalizations);
  }

  static const LocalizationsDelegate<MopperLocalizations> delegate =
      _MopperLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// Label for the floating action button that opens the feedback form
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackButtonLabel;

  /// Title shown in the app bar of the feedback form
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedbackTitle;

  /// Label for the description text field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Hint text for the description text field
  ///
  /// In en, this message translates to:
  /// **'Please describe the steps to reproduce or your specific suggestion...'**
  String get descriptionHint;

  /// Validation error when description field is empty
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// Label for the category choice chips
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Category chip label for UI/UX issues
  ///
  /// In en, this message translates to:
  /// **'UI/UX'**
  String get categoryUiUx;

  /// Category chip label for bugs
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get categoryBug;

  /// Category chip label for performance issues
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get categoryPerformance;

  /// Category chip label for feature requests
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get categoryFeature;

  /// Label for the optional name text field
  ///
  /// In en, this message translates to:
  /// **'Your Name (Optional)'**
  String get yourNameLabel;

  /// Hint text for the name text field
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex Chen'**
  String get yourNameHint;

  /// Label for the optional feedback title text field
  ///
  /// In en, this message translates to:
  /// **'Feedback Title (Optional)'**
  String get feedbackTitleLabel;

  /// Hint text for the feedback title text field
  ///
  /// In en, this message translates to:
  /// **'Brief summary of the issue'**
  String get feedbackTitleHint;

  /// Label for the discard button
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// Label for the submit feedback button
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitButton;

  /// Label shown when a screenshot is attached
  ///
  /// In en, this message translates to:
  /// **'Screenshot attached'**
  String get screenshotAttached;

  /// Label for the button to start annotating a screenshot
  ///
  /// In en, this message translates to:
  /// **'Annotate'**
  String get annotateButton;

  /// Label for the button to finish annotating
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// Badge text shown next to required fields
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get requiredBadge;

  /// Title for the system diagnostics section
  ///
  /// In en, this message translates to:
  /// **'System Diagnostics'**
  String get systemDiagnosticsTitle;

  /// Snackbar message shown when feedback is submitted successfully
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted successfully.'**
  String get feedbackSubmittedSuccess;

  /// Snackbar message shown when feedback submission fails
  ///
  /// In en, this message translates to:
  /// **'Failed: {errors}'**
  String feedbackSubmittedError(String errors);

  /// Loading overlay text shown while feedback is being submitted
  ///
  /// In en, this message translates to:
  /// **'Submitting feedback...'**
  String get submittingFeedback;
}

class _MopperLocalizationsDelegate
    extends LocalizationsDelegate<MopperLocalizations> {
  const _MopperLocalizationsDelegate();

  @override
  Future<MopperLocalizations> load(Locale locale) {
    return SynchronousFuture<MopperLocalizations>(
      lookupMopperLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_MopperLocalizationsDelegate old) => false;
}

MopperLocalizations lookupMopperLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return MopperLocalizationsEn();
    case 'nl':
      return MopperLocalizationsNl();
  }

  throw FlutterError(
    'MopperLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
