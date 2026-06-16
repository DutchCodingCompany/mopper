/// Data collected from the mopper form.
class MopperData {
  /// Creates a [MopperData] instance with the given form values.
  const MopperData({
    required this.description,
    this.title,
    this.userName,
    this.category,
    this.buildInfo,
    this.device,
    this.os,
  });

  /// Optional short title for the feedback.
  final String? title;

  /// The feedback description text (required).
  final String description;

  /// Optional name of the user submitting feedback.
  final String? userName;

  /// Optional category (e.g. 'bug', 'uiux', 'performance', 'feature').
  final String? category;

  /// Build version string (e.g. '1.0.0+1').
  final String? buildInfo;

  /// Device model name (e.g. 'iPhone 15 Pro').
  final String? device;

  /// Operating system info (e.g. 'iOS: 17.4').
  final String? os;
}

/// Callback type for submitting mopper data.
typedef OnMopperSubmit = Future<void> Function(MopperData data);
