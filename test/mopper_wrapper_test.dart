import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mopper/mopper.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _FakeIntegration implements MopperIntegration {
  final submissions = <MopperSubmission>[];

  @override
  Future<void> submit(MopperSubmission submission) async {
    submissions.add(submission);
  }
}

class _HostStrings {
  static _HostStrings? of(BuildContext context) =>
      Localizations.of<_HostStrings>(context, _HostStrings);
}

class _HostStringsDelegate extends LocalizationsDelegate<_HostStrings> {
  const new();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<_HostStrings> load(Locale locale) => SynchronousFuture(_HostStrings());

  @override
  bool shouldReload(_HostStringsDelegate old) => false;
}

final _packageInfo = PackageInfo(
  appName: 'test',
  packageName: 'nl.dcc.test',
  version: '1.0.0',
  buildNumber: '1',
);

Widget _wrapper(BuildContext context, Widget? child, MopperIntegration it) =>
    MopperWrapper(integrations: [it], packageInfo: _packageInfo, child: child!);

/// The form shows spinners while the screenshot and diagnostics load, so
/// pumpAndSettle would never return.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

final Finder _descriptionField = find.byWidgetPredicate(
  (widget) =>
      widget is TextField &&
      (widget.decoration?.hintText?.startsWith('Please describe') ?? false),
);

Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.check_circle_outline));
  await _settle(tester);
}

Future<void> _submitFeedback(
  WidgetTester tester,
  _FakeIntegration integration,
) async {
  await tester.tap(find.text('Feedback'));
  await _settle(tester);
  expect(find.text('Submit Feedback'), findsNWidgets(2));

  await _tapSubmit(tester);
  expect(integration.submissions, isEmpty);
  expect(find.text('Description is required'), findsOneWidget);

  await tester.enterText(_descriptionField, 'The button does nothing');
  await _tapSubmit(tester);
}

void main() {
  // Tall enough to show the whole form without scrolling; the form builds
  // its fields lazily.
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1600,
      9000,
    );
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
        .resetPhysicalSize();
  });

  testWidgets('works in an app built with package:flutter/material', (
    tester,
  ) async {
    final integration = _FakeIntegration();
    await tester.pumpWidget(
      legacy.MaterialApp(
        builder: (context, child) => _wrapper(context, child, integration),
        home: const legacy.Scaffold(body: legacy.Text('Host app')),
      ),
    );

    expect(find.text('Host app'), findsOneWidget);
    await _submitFeedback(tester, integration);

    expect(integration.submissions, hasLength(1));
    expect(
      integration.submissions.single.data.description,
      'The button does nothing',
    );
    expect(find.text('Feedback submitted successfully.'), findsOneWidget);
    expect(find.text('Feedback'), findsOneWidget);
  });

  testWidgets('works in an app built with package:material_ui', (tester) async {
    final integration = _FakeIntegration();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => _wrapper(context, child, integration),
        home: const Scaffold(body: Text('Host app')),
      ),
    );

    expect(find.text('Host app'), findsOneWidget);
    await _submitFeedback(tester, integration);

    expect(integration.submissions, hasLength(1));
    expect(find.text('Feedback submitted successfully.'), findsOneWidget);
    expect(find.text('Feedback'), findsOneWidget);
  });

  testWidgets('keeps the localizations of the host app', (tester) async {
    _HostStrings? hostStrings;
    await tester.pumpWidget(
      legacy.MaterialApp(
        localizationsDelegates: const [_HostStringsDelegate()],
        builder: (context, child) =>
            _wrapper(context, child, _FakeIntegration()),
        home: Builder(
          builder: (context) {
            hostStrings = _HostStrings.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(hostStrings, isNotNull);
  });

  testWidgets('lets taps through to the host app', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      legacy.MaterialApp(
        builder: (context, child) =>
            _wrapper(context, child, _FakeIntegration()),
        home: legacy.Scaffold(
          body: legacy.Center(
            child: legacy.TextButton(
              onPressed: () => taps++,
              child: const legacy.Text('Host button'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Host button'));
    expect(taps, 1);
  });
}
