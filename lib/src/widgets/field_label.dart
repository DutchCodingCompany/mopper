import 'package:dcc_toolkit/dcc_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:mopper/l10n/strings.dart';

/// A field label widget with optional REQUIRED indicator.
///
/// Used to label form fields throughout the mopper package.
class FieldLabel extends StatelessWidget {
  /// Creates a [FieldLabel] with the given [label] text.
  const FieldLabel({required this.label, this.required = false, super.key});

  /// The label text to display.
  final String label;

  /// Whether to show a "REQUIRED" badge.
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: Paddings.horizontal4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF393939),
            ),
          ),
        ),
        if (required) ...[
          const Spacer(),
          Text(
            context.mopperL10n.requiredBadge,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
