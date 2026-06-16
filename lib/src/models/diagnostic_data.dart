import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Data class to hold diagnostics information.
class DiagnosticsData {
  /// Creates a [DiagnosticsData] with the given values.
  const DiagnosticsData({
    required this.buildInfo,
    required this.device,
    required this.os,
  });

  /// Application build version (e.g. '1.0.0+1').
  final String buildInfo;

  /// Device model name (e.g. 'iPhone 15 Pro').
  final String device;

  /// Operating system info (e.g. 'iOS: 17.4').
  final String os;

  /// Loads diagnostics for the current platform.
  ///
  /// If [packageInfo] is provided it will be used directly, avoiding a
  /// redundant call to [PackageInfo.fromPlatform].
  static Future<DiagnosticsData> load(
    TargetPlatform platform, {
    PackageInfo? packageInfo,
  }) async {
    try {
      final info = packageInfo ?? await PackageInfo.fromPlatform();
      final deviceInfoPlugin = DeviceInfoPlugin();

      final (device, os) = switch (platform) {
        TargetPlatform.iOS => await _iosInfo(deviceInfoPlugin),
        TargetPlatform.android => await _androidInfo(deviceInfoPlugin),
        TargetPlatform.macOS => await _macOsInfo(deviceInfoPlugin),
        TargetPlatform.windows => await _windowsInfo(deviceInfoPlugin),
        TargetPlatform.linux => await _linuxInfo(deviceInfoPlugin),
        _ => ('Unknown Device', 'Unknown OS'),
      };

      return DiagnosticsData(
        buildInfo: '${info.version}+${info.buildNumber}',
        device: device,
        os: os,
      );
    } on Exception catch (_) {
      return const DiagnosticsData(
        buildInfo: 'Unknown',
        device: 'Unknown Device',
        os: 'Unknown OS',
      );
    }
  }

  static Future<(String, String)> _iosInfo(DeviceInfoPlugin plugin) async {
    final info = await plugin.iosInfo;
    return (info.model, 'iOS: ${info.systemVersion}');
  }

  static Future<(String, String)> _androidInfo(DeviceInfoPlugin plugin) async {
    final info = await plugin.androidInfo;
    return (info.model, 'Android: ${info.version.release}');
  }

  static Future<(String, String)> _macOsInfo(DeviceInfoPlugin plugin) async {
    final info = await plugin.macOsInfo;
    return (info.model, 'macOS');
  }

  static Future<(String, String)> _windowsInfo(DeviceInfoPlugin plugin) async {
    final info = await plugin.windowsInfo;
    return (info.computerName, 'Windows');
  }

  static Future<(String, String)> _linuxInfo(DeviceInfoPlugin plugin) async {
    final info = await plugin.linuxInfo;
    return (info.name, 'Linux: ${info.version}');
  }
}
