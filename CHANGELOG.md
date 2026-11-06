# 0.2.0
- **Breaking:** Requires Flutter `>=3.47.0` and Dart `^3.13.0`
- **Breaking:** Updated `sentry_flutter` to 10. Apps must use Android `minSdk` 26 or higher and Swift Package Manager on iOS and macOS, see the [Sentry migration guide](https://docs.sentry.io/platforms/dart/guides/flutter/migration/v9-to-v10/)
- **Breaking:** Updated `flutter_form_builder` to 11 and `dcc_toolkit` to 0.2.0
- Migrated from `package:flutter/material.dart` to `package:material_ui`. Mopper works in apps on either library
- Fixed: `MopperWrapper` hid the app's own localizations from every screen below it
- Fixed: focusing a text field in the feedback form failed because there was no `Overlay`
- Fixed: the snackbar after submitting feedback now shows in mopper's own style, also when the app uses `package:material_ui`
- Updated `device_info_plus`, `package_info_plus` and `very_good_analysis`

# 0.1.1
- Updated dcc_toolkit to 0.1.1

# 0.1.0

- Initial release.
- `MopperWrapper` widget for wrapping your app with feedback capture.
- Automatic screenshot capture via `RepaintBoundary`.
- Screenshot annotation tools (freehand draw, arrows, color picker).
- Built-in `GitLabIntegration` for creating issues with screenshots.
- Built-in `SentryFeedbackIntegration` for Sentry user feedback.
- Pluggable `MopperIntegration` interface for custom backends.
- Automatic system diagnostics collection (device, OS, build info).
- Localization support for English and Dutch.
- Themed feedback form with Material 3 design.
