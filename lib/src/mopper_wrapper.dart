import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dcc_toolkit/common/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mopper/l10n/strings.dart';
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
  Uint8List? _screenshot;
  bool _showDialog = false;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    if (widget.packageInfo != null) {
      _packageInfo = widget.packageInfo;
    } else {
      unawaited(_loadPackageInfo());
    }
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
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
    setState(() {
      _showDialog = true;
      _screenshot = null;
    });
    unawaited(_captureScreenshotAsync());
  }

  Future<void> _captureScreenshotAsync() async {
    final screenshot = await _captureScreenshot();
    if (!mounted || !_showDialog) return;
    setState(() => _screenshot = screenshot);
  }

  void _closeMopperDialog() {
    setState(() {
      _showDialog = false;
      _screenshot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(key: _boundaryKey, child: widget.child),
        if (!_showDialog)
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
        if (_showDialog)
          Positioned.fill(
            child: MopperDialog(
              screenshot: _screenshot,
              onClose: _closeMopperDialog,
              integrations: widget.integrations,
              packageInfo: _packageInfo,
            ),
          ),
      ],
    );
  }
}
