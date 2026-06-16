import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Controller managing the mopper wrapper state.
///
/// Handles dialog visibility, screenshot state management,
/// and package info loading.
class MopperWrapperController extends ChangeNotifier {
  /// Creates a [MopperWrapperController].
  ///
  /// If [packageInfo] is provided, it will be used directly. Otherwise
  /// [loadPackageInfo] must be called to load it from the platform.
  MopperWrapperController({PackageInfo? packageInfo})
    : _packageInfo = packageInfo;

  bool _showDialog = false;
  Uint8List? _screenshot;
  PackageInfo? _packageInfo;

  /// Whether the feedback dialog is currently visible.
  bool get showDialog => _showDialog;

  /// The captured screenshot bytes, or null if not yet captured.
  Uint8List? get screenshot => _screenshot;

  /// The loaded package info, or null if not yet available.
  PackageInfo? get packageInfo => _packageInfo;

  /// Loads package info from the platform.
  ///
  /// Does nothing if package info is already loaded.
  Future<void> loadPackageInfo() async {
    if (_packageInfo != null) return;

    _packageInfo = await PackageInfo.fromPlatform();
    notifyListeners();
  }

  /// Opens the feedback dialog and resets the screenshot.
  void openDialog() {
    _showDialog = true;
    _screenshot = null;
    notifyListeners();
  }

  /// Closes the feedback dialog and clears the screenshot.
  void closeDialog() {
    _showDialog = false;
    _screenshot = null;
    notifyListeners();
  }

  /// Updates the captured screenshot bytes.
  void setScreenshot(Uint8List? bytes) {
    _screenshot = bytes;
    notifyListeners();
  }
}
