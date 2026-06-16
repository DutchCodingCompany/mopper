import 'dart:typed_data';

import 'package:mopper/src/models/mopper_data.dart';

/// Abstract interface that all mopper integrations must implement.
///
/// Each integration handles submitting mopper to a specific backend
/// (e.g. GitLab, Sentry, Slack, etc.).
///
/// Example:
/// ```dart
/// class MyIntegration implements MopperIntegration {
///
///   @override
///   Future<void> submit(MopperSubmission submission) async {
///     // Upload to your service...
///   }
/// }
/// ```
// ignore: one_member_abstracts
abstract class MopperIntegration {
  /// Submit mopper to this integration.
  ///
  /// Throws on failure — the caller will catch and report which
  /// integration(s) failed.
  Future<void> submit(MopperSubmission submission);
}

/// Complete mopper payload passed to each [MopperIntegration].
class MopperSubmission {
  /// Creates a [MopperSubmission] with the given [data] and [screenshot].
  const MopperSubmission({required this.data, required this.screenshot});

  /// The form data (title, description, category, userName).
  final MopperData data;

  /// The (possibly annotated) screenshot PNG bytes.
  final Uint8List screenshot;
}
