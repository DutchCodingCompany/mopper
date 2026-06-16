import 'package:flutter/foundation.dart';
import 'package:mopper/src/models/diagnostic_data.dart';
import 'package:mopper/src/models/mopper_data.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Controller managing the feedback form state.
///
/// Handles diagnostics loading, annotation mode toggling, and building
/// [MopperData] from raw form values.
class MopperFormController extends ChangeNotifier {
  /// Creates a [MopperFormController].
  MopperFormController();

  DiagnosticsData? _diagnostics;
  bool _diagnosticsLoading = false;
  bool _isAnnotating = false;

  /// The loaded diagnostics data, or null if still loading.
  DiagnosticsData? get diagnostics => _diagnostics;

  /// Whether diagnostics are currently being loaded.
  bool get diagnosticsLoading => _diagnosticsLoading;

  /// Whether the user is currently in annotation mode.
  bool get isAnnotating => _isAnnotating;

  /// Loads system diagnostics for the given [platform].
  ///
  /// If [packageInfo] is provided it will be used directly, avoiding a
  /// redundant call to [PackageInfo.fromPlatform].
  ///
  /// Does nothing if diagnostics are already loading or loaded.
  Future<void> loadDiagnostics(
    TargetPlatform platform, {
    PackageInfo? packageInfo,
  }) async {
    if (_diagnosticsLoading || _diagnostics != null) return;

    _diagnosticsLoading = true;
    notifyListeners();

    _diagnostics = await DiagnosticsData.load(
      platform,
      packageInfo: packageInfo,
    );
    _diagnosticsLoading = false;
    notifyListeners();
  }

  /// Sets whether the user is currently annotating the screenshot.
  void setAnnotating({required bool annotating}) {
    if (_isAnnotating == annotating) return;
    _isAnnotating = annotating;
    notifyListeners();
  }

  /// Builds a [MopperData] from raw form values and loaded diagnostics.
  MopperData buildMopperData(Map<String, dynamic> formValues) {
    return MopperData(
      title: formValues['title'] as String?,
      description: formValues['description'] as String,
      userName: formValues['user'] as String?,
      category: formValues['category'] as String?,
      buildInfo: _diagnostics?.buildInfo,
      device: _diagnostics?.device,
      os: _diagnostics?.os,
    );
  }
}
