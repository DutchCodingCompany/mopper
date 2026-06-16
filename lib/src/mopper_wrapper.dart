import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dcc_toolkit/common/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mopper/l10n/mopper_localizations.dart';
import 'package:mopper/l10n/strings.dart';
import 'package:mopper/src/controllers/mopper_wrapper_controller.dart';
import 'package:mopper/src/integrations/mopper_integration.dart';
import 'package:mopper/src/mopper_dialog.dart';
import 'package:mopper/src/mopper_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Wraps the app in a [RepaintBoundary] for screenshot capture and overlays a
/// FAB that opens the mopper dialog.
///
/// The dialog is rendered as a full-screen overlay within the [Stack] to avoid
/// requiring a [Navigator] ancestor (since this widget sits above the router
/// in the `MaterialApp.builder`).
class MopperWrapper extends StatefulWidget {
  /// Creates a [MopperWrapper] with the given [integrations] and [child].
  const MopperWrapper({
    required this.integrations,
    required this.child,
    this.packageInfo,
    super.key,
  });

  /// The list of integrations to submit feedback to.
  final List<MopperIntegration> integrations;

  /// The child widget to wrap (your app content).
  final Widget child;

  /// Optional pre-loaded package info to avoid redundant platform calls.
  final PackageInfo? packageInfo;

  @override
  State<MopperWrapper> createState() => _MopperWrapperState();
}

class _MopperWrapperState extends State<MopperWrapper> {
  final GlobalKey<State<StatefulWidget>> _boundaryKey = GlobalKey();
  late final MopperWrapperController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MopperWrapperController(packageInfo: widget.packageInfo);
    unawaited(_controller.loadPackageInfo());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureScreenshot() async {
    // Small delay to ensure the render tree is fully painted.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final boundary = _boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;

    if (!mounted) return null;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  void _openMopperDialog() {
    _controller.openDialog();
    unawaited(_captureScreenshotAsync());
  }

  Future<void> _captureScreenshotAsync() async {
    final screenshot = await _captureScreenshot();
    if (!mounted || !_controller.showDialog) return;
    _controller.setScreenshot(screenshot);
  }

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: Localizations.localeOf(context),
      delegates: MopperLocalizations.localizationsDelegates,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              RepaintBoundary(key: _boundaryKey, child: widget.child),
              if (!_controller.showDialog)
                Positioned(
                  right: Sizes.px16,
                  bottom: 100,
                  child: ElevatedButton.icon(
                    style: MopperTheme.light.elevatedButtonTheme.style,
                    onPressed: _openMopperDialog,
                    label: Text(context.mopperL10n.feedbackButtonLabel),
                    icon: const Icon(Icons.feedback_outlined),
                  ),
                ),
              if (_controller.showDialog)
                Positioned.fill(
                  child: MopperDialog(
                    screenshot: _controller.screenshot,
                    onClose: _controller.closeDialog,
                    integrations: widget.integrations,
                    packageInfo: _controller.packageInfo,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
