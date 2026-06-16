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
      title: 'Mopper Example',
      localizationsDelegates: const [MopperLocalizations.delegate],
      builder: (context, child) {
        return MopperWrapper(
          integrations: [
            // Submit feedback as GitLab issues with screenshots attached.
            const GitLabIntegration(
              projectId: '12345',
              apiToken: 'glpat-xxxxxxxxxxxx',
              gitlabUrl: 'gitlab.com',
            ),
            // Submit feedback via Sentry's user feedback API.
            SentryFeedbackIntegration(),
          ],
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mopper Example')),
      body: const Center(
        child: Text('Tap the feedback button to submit feedback.'),
      ),
    );
  }
}
