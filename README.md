# Mopper

In Dutch, *mopperen* means **to grumble** or **to complain**. This package turns those grumbles into actionable feedback — captured right inside your Flutter app.

**Mopper** is an in-app feedback widget that wraps your application, captures screenshots with annotation tools, collects device diagnostics, and dispatches submissions to configurable backends like GitLab and Sentry.

## Table of contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Integrations](#integrations)
- [Localization](#localization)
- [Additional information](#additional-information)

## Features

- Wrap any Flutter app with a single widget to enable feedback capture.
- Automatic screenshot capture via `RepaintBoundary`.
- Annotation tools: freehand draw, arrows, undo, and color picker.
- Built-in integrations for GitLab (issues) and Sentry (user feedback).
- Pluggable integration architecture — implement `MopperIntegration` for any backend.
- Automatic system diagnostics (device model, OS version, app build info).
- Themed feedback form with Material 3 design (scoped, won't affect your app).
- Localization support (English and Dutch).

## Installation

```yaml
dependencies:
  mopper: ^0.1.0
```

## Usage

Wrap your app with `MopperWrapper` in `MaterialApp.builder`. This adds a floating action button that opens the feedback form when tapped.

```dart
import 'package:flutter/material.dart';
import 'package:mopper/mopper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add MopperLocalizations.delegate alongside your other delegates
      localizationsDelegates: const [
        MopperLocalizations.delegate,
      ],
      builder: (context, child) {
        return MopperWrapper(
          integrations: [
            GitLabIntegration(
              projectId: '12345',
              apiToken: 'glpat-xxxxxxxxxxxx',
              gitlabUrl: 'gitlab.com',
            ),
            SentryFeedbackIntegration(),
          ],
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MyHomePage(),
    );
  }
}
```

The `MopperWrapper` will:
1. Wrap your app in a `RepaintBoundary` for screenshot capture.
2. Overlay a floating "Feedback" button.
3. Open a full-screen feedback form with screenshot annotation, category selection, and diagnostics.
4. Submit feedback in parallel to all configured integrations.

## Integrations

### GitLab

Creates a GitLab issue with the annotated screenshot attached:

```dart
GitLabIntegration(
  projectId: '12345',
  apiToken: 'glpat-xxxxxxxxxxxx',
  gitlabUrl: 'gitlab.com', // or your self-hosted instance
)
```

### Sentry

Submits feedback via Sentry's `captureFeedback` API with the screenshot as an attachment:

```dart
SentryFeedbackIntegration()
```

### Custom integration

Implement the `MopperIntegration` interface to add your own backend:

```dart
class SlackIntegration implements MopperIntegration {
  @override
  String get name => 'Slack';

  @override
  Future<void> submit(MopperSubmission submission) async {
    // Upload screenshot and post message to Slack...
  }
}
```

## Localization

Mopper ships with English and Dutch translations. Add `MopperLocalizations.delegate` to your `localizationsDelegates`:

```dart
MaterialApp(
  localizationsDelegates: const [
    MopperLocalizations.delegate,
    // ... your other delegates
  ],
)
```

## Additional information

This package is maintained by [Dutch Coding Company](https://dutchcodingcompany.com). Feel free to leave feedback or open a pull request on [GitHub](https://github.com/DutchCodingCompany/mopper).
