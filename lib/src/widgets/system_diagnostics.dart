import 'package:dcc_toolkit/dcc_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:mopper/l10n/strings.dart';

import 'package:mopper/src/models/diagnostic_data.dart';

/// A widget that displays system diagnostics information.
///
/// Accepts an optional [data] parameter. When non-null the diagnostics are
/// displayed immediately; when null a loading spinner is shown.
class SystemDiagnostics extends StatelessWidget {
  /// Creates a [SystemDiagnostics] widget.
  const SystemDiagnostics({super.key, this.data});

  /// The diagnostics data to display. Shows a spinner when null.
  final DiagnosticsData? data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: Paddings.all16,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: Radiuses.circular8,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.outline),
              Margins.horizontal8,
              Text(
                context.mopperL10n.systemDiagnosticsTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Margins.vertical8,
          if (data == null)
            const Padding(
              padding: Paddings.vertical8,
              child: SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            Text(
              'Build: ${data!.buildInfo}'
              ' | Device: ${data!.device}'
              ' | OS: ${data!.os}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }
}
