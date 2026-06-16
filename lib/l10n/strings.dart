import 'package:flutter/widgets.dart';
import 'package:mopper/l10n/mopper_localizations.dart';

/// Convenience extension for accessing [MopperLocalizations] from a
/// [BuildContext].
extension MopperLocalizationsX on BuildContext {
  /// Returns the [MopperLocalizations] instance for the current locale.
  MopperLocalizations get mopperL10n => MopperLocalizations.of(this)!;
}
