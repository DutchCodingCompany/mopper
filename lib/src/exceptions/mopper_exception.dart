/// Exception thrown when mopper upload fails.
class MopperUploadException implements Exception {
  /// Creates a [MopperUploadException] with the given [message].
  MopperUploadException(this.message);

  /// A human-readable description of the upload failure.
  final String message;

  @override
  String toString() => 'MopperUploadException: $message';
}
