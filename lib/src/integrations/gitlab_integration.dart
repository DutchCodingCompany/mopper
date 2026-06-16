import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mopper/src/exceptions/mopper_exception.dart';
import 'package:mopper/src/integrations/mopper_integration.dart';
import 'package:mopper/src/models/mopper_data.dart';

/// Built-in GitLab integration that creates issues with attached screenshots.
///
/// Uploads the screenshot to the GitLab project, then creates an issue
/// with the mopper description and the embedded image.
class GitLabIntegration implements MopperIntegration {
  /// Creates a [GitLabIntegration] for the given GitLab project.
  const GitLabIntegration({
    required this.projectId,
    required this.apiToken,
    required this.gitlabUrl,
  });

  /// GitLab project ID where mopper issues will be created.
  final String projectId;

  /// GitLab API token for authentication.
  final String apiToken;

  /// GitLab base URL (e.g. 'gitlab.com', 'gitlab.dcc.tools').
  final String gitlabUrl;

  @override
  String get name => 'GitLab';

  @override
  Future<void> submit(MopperSubmission submission) async {
    final baseUrl = 'https://$gitlabUrl/api/v4/projects/$projectId';
    final screenshot = submission.screenshot.isEmpty
        ? Uint8List(0)
        : submission.screenshot;

    // Step 1: Upload screenshot
    final imageMarkdown = await _uploadScreenshot(
      baseUrl: baseUrl,
      screenshot: screenshot,
    );

    // Step 2: Create issue
    await _createIssue(
      baseUrl: baseUrl,
      title: submission.data.title ?? 'User Feedback',
      description: _composeDescription(submission.data),
      imageMarkdown: imageMarkdown,
      extras: {
        'category': submission.data.category,
        if (submission.data.userName != null) 'user': submission.data.userName,
      },
    );
  }

  Future<String> _uploadScreenshot({
    required String baseUrl,
    required Uint8List screenshot,
  }) async {
    final uri = Uri.parse('$baseUrl/uploads');

    final request = http.MultipartRequest('POST', uri)
      ..headers['PRIVATE-TOKEN'] = apiToken
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          screenshot,
          filename: 'feedback.png',
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw MopperUploadException(
        'Failed to upload screenshot: ${response.statusCode} ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['markdown'] as String? ?? 'Missing image!';
  }

  Future<void> _createIssue({
    required String baseUrl,
    required String title,
    required String description,
    required String imageMarkdown,
    Map<String, dynamic>? extras,
  }) async {
    final issueDescription = StringBuffer()
      ..writeln(description)
      ..writeln()
      ..writeln(imageMarkdown);

    if (extras != null && extras.isNotEmpty) {
      issueDescription
        ..writeln()
        ..writeln('---')
        ..writeln('**Extras:** $extras');
    }

    final uri = Uri.parse('$baseUrl/issues');

    final response = await http.post(
      uri,
      headers: {'PRIVATE-TOKEN': apiToken, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': issueDescription.toString(),
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw MopperUploadException(
        'Failed to create issue: ${response.statusCode} ${response.body}',
      );
    }
  }

  String _composeDescription(MopperData data) {
    final buffer = StringBuffer()..writeln(data.description);

    if (data.category != null) {
      buffer.writeln('\n**Category:** ${data.category}');
    }
    if (data.userName != null && data.userName!.isNotEmpty) {
      buffer.writeln('**Reported by:** ${data.userName}');
    }
    if (data.buildInfo != null) {
      buffer.writeln('**Build info:** ${data.buildInfo}');
    }
    if (data.device != null) {
      buffer.writeln('**App version:** ${data.device}');
    }
    if (data.os != null) {
      buffer.writeln('**OS:** ${data.os}');
    }

    return buffer.toString();
  }
}
